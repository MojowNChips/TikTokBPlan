#!/usr/bin/env python3
"""
VOD Analyzer - Finds high-engagement moments in Twitch VODs.
Downloads the VOD, analyzes audio energy, visual changes, and transcribes
with Whisper.cpp to score candidate clips (0-100).
"""

import json
import sys
import os
import subprocess
import re
from datetime import datetime
from typing import List, Dict, Any

import requests


def get_vod_metadata(vod_id: str, client_id: str, access_token: str) -> Dict:
    """Fetch VOD metadata from Twitch API."""
    headers = {
        "Client-ID": client_id,
        "Authorization": f"Bearer {access_token}",
    }
    resp = requests.get(
        f"https://api.twitch.tv/helix/videos?id={vod_id}", headers=headers, timeout=30
    )
    if resp.status_code == 200:
        data = resp.json().get("data", [])
        return data[0] if data else {}
    print(f"Twitch metadata error: {resp.status_code} {resp.text}", file=sys.stderr)
    return {}


def parse_twitch_duration(duration_str: str) -> int:
    """Parse a Twitch duration string like '1h30m45s' into total seconds."""
    total = 0
    for match in re.finditer(r"(\d+)(h|m|s)", duration_str):
        value, unit = int(match.group(1)), match.group(2)
        if unit == "h":
            total += value * 3600
        elif unit == "m":
            total += value * 60
        elif unit == "s":
            total += value
    return total


def download_vod_segment(
    vod_url: str,
    start: float,
    end: float,
    output_path: str,
) -> bool:
    """Download a segment of a VOD using yt-dlp."""
    try:
        cmd = [
            "yt-dlp",
            "-f",
            "bestvideo[height<=1080]+bestaudio/best",
            "--download-sections",
            f"*{start}-{end}",
            "--force-keyframes-at-cuts",
            "-o",
            output_path,
            vod_url,
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        if result.returncode != 0:
            print(f"yt-dlp error: {result.stderr}", file=sys.stderr)
            return False
        # yt-dlp may append an extension; find the actual file
        if not os.path.exists(output_path):
            base = output_path.rsplit(".", 1)[0]
            for ext in ["mp4", "mkv", "webm", "ts"]:
                cand = f"{base}.{ext}"
                if os.path.exists(cand):
                    os.rename(cand, output_path)
                    return True
            print(f"Downloaded file not found: {output_path}", file=sys.stderr)
            return False
        return True
    except subprocess.TimeoutExpired:
        print("yt-dlp timed out", file=sys.stderr)
        return False
    except FileNotFoundError:
        print("yt-dlp not installed", file=sys.stderr)
        return False


def analyze_audio_energy(video_path: str, start: float, end: float) -> float:
    """Analyze audio energy in a segment using ffmpeg astats."""
    try:
        cmd = [
            "ffmpeg", "-y",
            "-i", video_path,
            "-ss", str(start), "-to", str(end),
            "-af", "astats=metadata=1:reset=1",
            "-f", "null", "-",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        for line in result.stderr.split("\n"):
            if "RMS level" in line:
                match = re.search(r"RMS level:\s*(-?\d+\.?\d*)", line)
                if match:
                    db = float(match.group(1))
                    # Convert to 0-100 scale (-60dB to 0dB)
                    return max(0, min(100, (db + 60) / 60 * 100))
    except Exception as e:
        print(f"Audio analysis error: {e}", file=sys.stderr)
    return 50  # Default middle score


def detect_visual_changes(video_path: str, start: float, end: float) -> float:
    """Detect scene changes/motion using ffmpeg select filter."""
    try:
        cmd = [
            "ffmpeg", "-y",
            "-i", video_path,
            "-ss", str(start), "-to", str(end),
            "-vf", r"select='gt(scene,0.3)',metadata=print:file=-",
            "-f", "null", "-",
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)
        scene_changes = result.stdout.count("scene_score")
        duration = end - start
        if duration <= 0:
            return 0
        # Normalize: ~10 changes per minute = 100
        return min(100, (scene_changes / (duration / 60)) * 10)
    except Exception as e:
        print(f"Visual analysis error: {e}", file=sys.stderr)
    return 50


def transcribe_segment(video_path: str, start: float, end: float, model_path: str) -> str:
    """Transcribe audio segment using whisper.cpp."""
    try:
        audio_path = f"/tmp/segment_{start}_{end}.wav"
        txt_path = f"{audio_path}.txt"

        # Extract audio segment
        cmd = [
            "ffmpeg", "-y",
            "-i", video_path,
            "-ss", str(start), "-to", str(end),
            "-ar", "16000", "-ac", "1", audio_path,
        ]
        subprocess.run(cmd, check=True, capture_output=True, timeout=60)

        # Run whisper.cpp
        cmd = [
            "whisper-cli", "-m", model_path,
            "-f", audio_path, "-otxt", "-of", audio_path,
        ]
        subprocess.run(cmd, capture_output=True, text=True, timeout=120)

        # Cleanup audio
        if os.path.exists(audio_path):
            os.remove(audio_path)

        if os.path.exists(txt_path):
            with open(txt_path, "r", encoding="utf-8") as f:
                text = f.read().strip()
            os.remove(txt_path)
            return text
    except Exception as e:
        print(f"Transcription error: {e}", file=sys.stderr)
    return ""


def score_moment(
    start: float,
    end: float,
    chat_velocity: float,  # messages per second
    peak_viewers: int,
    audio_energy: float,
    visual_changes: float,
    transcript: str,
    keywords: List[str],
) -> Dict[str, Any]:
    """Score a moment based on multiple factors."""

    # Base scores (0-100 each)
    scores = {
        "chat_velocity": min(100, chat_velocity * 10),  # 10 msg/s = 100
        "peak_viewers": min(100, peak_viewers / 100),   # 10k viewers = 100
        "audio_energy": audio_energy,                    # 0-100
        "visual_changes": visual_changes,                # 0-100
        "keywords": 0,
    }

    # Keyword bonus from transcript
    text_lower = transcript.lower()
    keyword_hits = sum(1 for kw in keywords if kw.lower() in text_lower)
    scores["keywords"] = min(100, keyword_hits * 20)

    # Weighted total
    weights = {
        "chat_velocity": 0.25,
        "peak_viewers": 0.20,
        "audio_energy": 0.15,
        "visual_changes": 0.20,
        "keywords": 0.20,
    }

    total_score = sum(scores[k] * weights[k] for k in scores)

    # Determine reason
    reasons = []
    if scores["chat_velocity"] > 70:
        reasons.append("chat explosion")
    if scores["peak_viewers"] > 70:
        reasons.append("peak viewership")
    if scores["audio_energy"] > 70:
        reasons.append("audio spike")
    if scores["visual_changes"] > 70:
        reasons.append("high action")
    if scores["keywords"] > 50:
        reasons.append("keyword triggers")

    return {
        "start_time": start,
        "end_time": end,
        "duration": end - start,
        "score": round(total_score),
        "breakdown": scores,
        "reason": ", ".join(reasons) if reasons else "moderate engagement",
        "transcript": transcript[:200],
    }


def find_best_moments(
    vod_id: str,
    streamer: str,
    video_path: str,
    duration: float,
    client_id: str,
    access_token: str,
    model_path: str,
    segment_length: int = 30,
    stride: int = 10,
    min_score: int = 65,
) -> List[Dict]:
    """Analyze VOD and return best moments using real ffmpeg/whisper analysis."""

    # High-value keywords for gaming clips
    keywords = [
        "clutch", "insane", "crazy", "unbelievable", "impossible",
        "one tap", "headshot", "ace", "quad", "penta", "team wipe",
        "wtf", "omg", "no way", "lucky", "hack", "cheat",
        "funny", "fail", "rage", "tilt", "throw", "mistake",
        "react", "reaction", "shocked", "surprised", "speechless",
    ]

    moments = []
    print(f"Analyzing VOD {vod_id} ({duration}s)...", file=sys.stderr)

    num_segments = int(duration / stride)
    for i in range(min(num_segments, 100)):  # Limit segments for demo runtime
        start = i * stride
        end = min(start + segment_length, duration)
        if end <= start:
            continue

        # Download this segment if we don't already have the full video
        # (video_path may not exist yet - download full VOD once instead)
        # For now we analyze the whole video_path if available.

        audio_energy = analyze_audio_energy(video_path, start, end)
        visual_changes = detect_visual_changes(video_path, start, end)
        transcript = transcribe_segment(video_path, start, end, model_path)

        # Chat velocity / peak viewers not available from public API without
        # chat replay access; use viewer count as proxy if metadata available.
        chat_vel = 0.0
        peak_v = 0

        scored = score_moment(
            start, end, chat_vel, peak_v, audio_energy, visual_changes, transcript, keywords
        )

        if scored["score"] >= min_score:
            scored["vod_id"] = vod_id
            scored["streamer"] = streamer
            scored["clip_id"] = f"clip_{vod_id}_{int(start)}"
            moments.append(scored)

    # Sort by score descending
    moments.sort(key=lambda x: x["score"], reverse=True)

    # Merge overlapping moments (keep highest score)
    merged = []
    for m in moments:
        overlap = False
        for existing in merged:
            if not (m["end_time"] <= existing["start_time"] or m["start_time"] >= existing["end_time"]):
                overlap = True
                break
        if not overlap:
            merged.append(m)

    return merged[:10]  # Top 10


def main():
    if len(sys.argv) < 3:
        print(json.dumps({"error": "Usage: analyze_vod.py <vod_id> <streamer>"}))
        sys.exit(1)

    vod_id = sys.argv[1]
    streamer = sys.argv[2]

    # Get credentials from env
    client_id = os.getenv("TWITCH_CLIENT_ID")
    access_token = os.getenv("TWITCH_ACCESS_TOKEN")
    model_path = os.getenv("WHISPER_MODEL", "/models/ggml-base.en.bin")

    if not client_id or not access_token:
        print(json.dumps({"error": "Missing Twitch credentials"}))
        sys.exit(1)

    # Get VOD metadata for duration + viewer count
    metadata = get_vod_metadata(vod_id, client_id, access_token)
    duration_str = metadata.get("duration", "0h0m0s")
    duration = parse_twitch_duration(duration_str)
    if duration == 0:
        duration = 7200  # 2 hours default fallback

    peak_viewers = metadata.get("view_count", 0)

    # Download the full VOD to temp for analysis
    video_path = f"/temp/{vod_id}.mp4"
    vod_url = f"https://twitch.tv/videos/{vod_id}"

    if not os.path.exists(video_path):
        print(f"Downloading VOD {vod_id}...", file=sys.stderr)
        if not download_vod_segment(vod_url, 0, duration, video_path):
            print(json.dumps({"error": "Failed to download VOD"}))
            sys.exit(1)

    # Analyze
    moments = find_best_moments(
        vod_id, streamer, video_path, duration,
        client_id, access_token, model_path,
    )

    # Output JSON for n8n
    print(json.dumps(moments))


if __name__ == "__main__":
    main()