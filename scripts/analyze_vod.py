#!/usr/bin/env python3
"""
VOD Analyzer - finds high-engagement moments in a Twitch VOD.

Usage: analyze_vod.py <vod_id> <streamer>
Prints a JSON array of clip candidates on stdout (logs go to stderr), each:
  {clip_id, vod_id, streamer, start_time, end_time, duration, score, reason, transcript, breakdown}

How it works (fits a 1 vCPU / 2 GB droplet):
  1. Download the VOD once at 160p (video+audio) via twitch_section.py, capped at MAX_ANALYZE_SECONDS.
  2. One ffmpeg pass for loudness (RMS every 10 s) and one for scene changes (2 fps, 160 px).
  3. Score every 30 s window (10 s stride) relative to the rest of the VOD (percentiles),
     so a quiet streamer's loud moments still stand out.
  4. Transcribe only the TOP_CANDIDATES windows with whisper.cpp and add a keyword score.
  5. Merge overlapping windows and return the best MAX_RESULTS.

Env: TWITCH_CLIENT_ID + TWITCH_CLIENT_SECRET (an app token is fetched automatically;
TWITCH_ACCESS_TOKEN is used instead if set), WHISPER_MODEL, MAX_ANALYZE_SECONDS (default 14400),
CLIP_WINDOW (clip length in s, default 30), TOP_CANDIDATES (default 20), MAX_RESULTS (default 10), KEEP_VOD_FILE=1 to keep the download.
"""

import json
import os
import re
import subprocess
import sys
from bisect import bisect_left
from typing import Dict, List

import requests

from twitch_section import fetch_section  # same folder (/scripts)

WINDOW = int(os.getenv("CLIP_WINDOW", "30"))  # seconds per clip (Creator Rewards pays only on videos > 60 s; use 65+)
STRIDE = 10          # seconds between window starts (= loudness chunk size)
KEYWORDS = [
    "clutch", "insane", "crazy", "unbelievable", "impossible",
    "one tap", "headshot", "ace", "quad", "penta", "team wipe",
    "wtf", "omg", "no way", "lucky", "hack", "cheat",
    "funny", "fail", "rage", "tilt", "throw", "mistake",
    "react", "reaction", "shocked", "surprised", "speechless",
    "let's go", "lets go", "oh my god", "what the",
]
WEIGHTS = {"audio_energy": 0.35, "visual_changes": 0.30, "keywords": 0.35}


def log(*a):
    print(*a, file=sys.stderr, flush=True)


# ------------------------------------------------------------------ Twitch
def twitch_token(client_id: str) -> str:
    tok = os.getenv("TWITCH_ACCESS_TOKEN")
    if tok:
        return tok
    secret = os.getenv("TWITCH_CLIENT_SECRET")
    if not (client_id and secret):
        return ""
    r = requests.post("https://id.twitch.tv/oauth2/token", params={
        "client_id": client_id, "client_secret": secret, "grant_type": "client_credentials"}, timeout=30)
    r.raise_for_status()
    return r.json()["access_token"]


def get_vod_metadata(vod_id: str, client_id: str, token: str) -> Dict:
    r = requests.get("https://api.twitch.tv/helix/videos", params={"id": vod_id},
                     headers={"Client-ID": client_id, "Authorization": f"Bearer {token}"}, timeout=30)
    if r.status_code != 200:
        log(f"Twitch metadata error: {r.status_code} {r.text[:200]}")
        return {}
    data = r.json().get("data", [])
    return data[0] if data else {}


def parse_twitch_duration(s: str) -> int:
    mult = {"h": 3600, "m": 60, "s": 1}
    return sum(int(v) * mult[u] for v, u in re.findall(r"(\d+)([hms])", s or ""))


# ------------------------------------------------------------------ media
def download_vod(vod_url: str, seconds: int, out_path: str) -> bool:
    """First <seconds> of the VOD at 160p (plenty for loudness/scene analysis, ~60 MB per hour)."""
    try:
        res = fetch_section(vod_url, 0, seconds, out_path, max_height=160)
        log(f"Downloaded {res['segments']} segments")
        return True
    except Exception as e:  # noqa: BLE001
        log(f"Download error: {e}")
        return False


def media_duration(path: str) -> float:
    r = subprocess.run(["ffprobe", "-v", "error", "-show_entries", "format=duration", "-of", "csv=p=0", path],
                       capture_output=True, text=True)
    try:
        return float(r.stdout.strip())
    except ValueError:
        return 0.0


def loudness_per_chunk(path: str, tmp: str) -> List[float]:
    """RMS level (dB) for each STRIDE-second chunk, in one ffmpeg pass."""
    out = f"{tmp}_rms.txt"
    sr = 8000
    af = (f"aresample={sr},asetnsamples=n={sr * STRIDE}:p=0,astats=metadata=1:reset=1,"
          f"ametadata=mode=print:key=lavfi.astats.Overall.RMS_level:file={out}")
    subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-y", "-i", path, "-vn", "-af", af, "-f", "null", "-"],
                   capture_output=True, text=True)
    levels = []
    if os.path.exists(out):
        for line in open(out, encoding="utf-8", errors="ignore"):
            if "RMS_level=" in line:
                v = line.split("=", 1)[1].strip()
                levels.append(-90.0 if v in ("-inf", "inf", "nan") else float(v))
        os.remove(out)
    return levels


def scene_change_times(path: str, tmp: str) -> List[float]:
    """Timestamps of scene cuts / big motion, in one low-res ffmpeg pass."""
    out = f"{tmp}_scene.txt"
    vf = f"fps=2,scale=160:-2,select='gt(scene,0.3)',metadata=mode=print:file={out}"
    subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-y", "-i", path, "-an", "-vf", vf, "-f", "null", "-"],
                   capture_output=True, text=True)
    times = []
    if os.path.exists(out):
        for line in open(out, encoding="utf-8", errors="ignore"):
            m = re.search(r"pts_time:([\d.]+)", line)
            if m:
                times.append(float(m.group(1)))
        os.remove(out)
    return sorted(times)


def transcribe(path: str, start: float, end: float, model: str, tmp: str) -> str:
    if not os.path.exists(model):
        return ""
    wav = f"{tmp}_{int(start)}.wav"
    try:
        subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-y", "-ss", str(start), "-to", str(end), "-i", path,
                        "-ar", "16000", "-ac", "1", wav], check=True, capture_output=True, timeout=120)
        r = subprocess.run(["whisper-cli", "-m", model, "-f", wav, "-nt", "-np", "-t", str(os.cpu_count() or 1)],
                           capture_output=True, text=True, timeout=300)
        return " ".join(r.stdout.split())
    except Exception as e:  # noqa: BLE001
        log(f"Transcription error at {start}s: {e}")
        return ""
    finally:
        if os.path.exists(wav):
            os.remove(wav)


# ------------------------------------------------------------------ scoring
def percentiles(values: List[float]) -> List[float]:
    """Rank of each value within the list, 0-100."""
    if not values:
        return []
    order = sorted(values)
    n = len(order)
    return [100.0 * bisect_left(order, v) / max(1, n - 1) for v in values]


def score(audio_pct: float, visual_pct: float, transcript: str) -> Dict:
    text = transcript.lower()
    hits = [k for k in KEYWORDS if k in text]
    parts = {"audio_energy": round(audio_pct, 1), "visual_changes": round(visual_pct, 1),
             "keywords": min(100, len(hits) * 25)}
    total = sum(parts[k] * w for k, w in WEIGHTS.items())
    reasons = []
    if audio_pct >= 85:
        reasons.append("audio spike")
    if visual_pct >= 85:
        reasons.append("high action")
    if hits:
        reasons.append("said: " + ", ".join(hits[:3]))
    return {"score": round(total), "breakdown": parts, "reason": "; ".join(reasons) or "moderate engagement"}


def find_best_moments(vod_id: str, streamer: str, path: str, model: str, tmp: str) -> List[Dict]:
    duration = media_duration(path)
    log(f"Analyzing {duration:.0f}s of VOD {vod_id}...")
    rms = loudness_per_chunk(path, tmp)
    cuts = scene_change_times(path, tmp)
    per_window = WINDOW // STRIDE

    windows = []
    for i in range(max(0, len(rms) - per_window + 1)):
        start = i * STRIDE
        end = min(start + WINDOW, duration)
        if end - start < WINDOW / 2:
            continue
        audio = sum(rms[i:i + per_window]) / per_window
        visual = bisect_left(cuts, end) - bisect_left(cuts, start)
        windows.append({"start": start, "end": end, "audio": audio, "visual": visual})
    if not windows:
        return []

    for w, a, v in zip(windows, percentiles([w["audio"] for w in windows]), percentiles([w["visual"] for w in windows])):
        w["audio_pct"], w["visual_pct"] = a, v
        w["pre"] = WEIGHTS["audio_energy"] * a + WEIGHTS["visual_changes"] * v

    # Transcribe only the strongest, non-overlapping candidates.
    top_n = int(os.getenv("TOP_CANDIDATES", "20"))
    candidates = []
    for w in sorted(windows, key=lambda w: w["pre"], reverse=True):
        if all(w["end"] <= c["start"] or w["start"] >= c["end"] for c in candidates):
            candidates.append(w)
        if len(candidates) >= top_n:
            break

    moments = []
    for w in candidates:
        text = transcribe(path, w["start"], w["end"], model, tmp)
        s = score(w["audio_pct"], w["visual_pct"], text)
        moments.append({
            "clip_id": f"clip_{vod_id}_{int(w['start'])}", "vod_id": vod_id, "streamer": streamer,
            "start_time": w["start"], "end_time": round(w["end"]), "duration": round(w["end"] - w["start"]),
            "transcript": text[:200], **s,
        })
    moments.sort(key=lambda m: m["score"], reverse=True)
    return moments[: int(os.getenv("MAX_RESULTS", "10"))]


def main():
    if len(sys.argv) < 3:
        print(json.dumps({"error": "Usage: analyze_vod.py <vod_id> <streamer>"}))
        sys.exit(1)
    vod_id, streamer = sys.argv[1], sys.argv[2]
    client_id = os.getenv("TWITCH_CLIENT_ID", "")
    model = os.getenv("WHISPER_MODEL", "/models/ggml-base.en.bin")
    if not os.path.exists(model):
        log(f"WARNING: Whisper model not found at {model}; keyword scoring disabled.")

    limit = int(os.getenv("MAX_ANALYZE_SECONDS", "14400"))
    try:
        token = twitch_token(client_id)
        meta = get_vod_metadata(vod_id, client_id, token) if token else {}
    except requests.RequestException as e:
        log(f"Twitch API error: {e}")
        meta = {}
    vod_len = parse_twitch_duration(meta.get("duration", "")) or limit
    seconds = min(vod_len, limit)

    os.makedirs("/temp", exist_ok=True)
    path = f"/temp/{vod_id}_analysis.mp4"
    tmp = f"/temp/{vod_id}_an"
    if not os.path.exists(path):
        log(f"Downloading VOD {vod_id} (first {seconds}s, 160p)...")
        if not download_vod(f"https://www.twitch.tv/videos/{vod_id}", seconds, path):
            print(json.dumps({"error": "Failed to download VOD"}))
            sys.exit(1)
    try:
        moments = find_best_moments(vod_id, streamer, path, model, tmp)
    finally:
        if os.getenv("KEEP_VOD_FILE") != "1" and os.path.exists(path):
            os.remove(path)
    print(json.dumps(moments))


if __name__ == "__main__":
    main()
