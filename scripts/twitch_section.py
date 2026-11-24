#!/usr/bin/env python3
"""
Download seconds [start, end] of a Twitch VOD by fetching only the HLS segments that cover them.

Why: Twitch serves VODs as fragmented-MP4 HLS playlists, and ffmpeg's HLS reader (which
yt-dlp --download-sections relies on) stalls on them ("m3u8 list sequence may have been wrapped").
This reads the playlist directly, downloads the needed segments, and joins them with no re-encode.

Usage:  twitch_section.py <vod_url> <start_s> <end_s> <out.mp4> [max_height=1080]
Prints: {"path": out, "offset": s, "duration": s, "segments": n}
        `offset` = where <start_s> falls inside the output file (segments are ~2-10 s long),
        so trim with:  ffmpeg -ss <offset> -t <duration> -i <out.mp4> ...
"""

import json
import os
import subprocess
import sys
import urllib.parse

import requests


def playlist_url(vod_url: str, max_height: int) -> str:
    fmt = f"best[height<={max_height}][vcodec!=none]/best[height<={max_height}]/best"
    r = subprocess.run(["yt-dlp", "-g", "-f", fmt, "--no-warnings", vod_url],
                       capture_output=True, text=True, timeout=180)
    if r.returncode != 0 or not r.stdout.strip():
        raise RuntimeError(f"yt-dlp could not resolve {vod_url}: {r.stderr.strip()[-400:]}")
    return r.stdout.strip().splitlines()[-1]


def parse_playlist(text: str, base: str):
    init, segments, t, dur = None, [], 0.0, None
    for line in text.splitlines():
        line = line.strip()
        if line.startswith("#EXT-X-MAP:") and 'URI="' in line:
            init = urllib.parse.urljoin(base, line.split('URI="', 1)[1].split('"', 1)[0])
        elif line.startswith("#EXTINF:"):
            dur = float(line[len("#EXTINF:"):].split(",")[0])
        elif line and not line.startswith("#") and dur is not None:
            segments.append((t, dur, urllib.parse.urljoin(base, line)))
            t += dur
            dur = None
    return init, segments


def fetch_section(vod_url: str, start: float, end: float, out: str, max_height: int = 1080) -> dict:
    m3u8 = playlist_url(vod_url, max_height)
    s = requests.Session()
    s.headers["User-Agent"] = "Mozilla/5.0"
    r = s.get(m3u8, timeout=30)
    r.raise_for_status()
    init, segments = parse_playlist(r.text, m3u8)
    if not segments:
        raise RuntimeError("playlist has no segments")
    total = segments[-1][0] + segments[-1][1]
    end = min(end, total)
    picked = [seg for seg in segments if seg[0] + seg[1] > start and seg[0] < end]
    if not picked:
        raise RuntimeError(f"no segments between {start}s and {end}s (VOD is {total:.0f}s)")

    part = out + ".part"
    with open(part, "wb") as f:
        if init:
            f.write(s.get(init, timeout=60).content)
        for _, _, url in picked:
            for attempt in range(3):
                try:
                    seg = s.get(url, timeout=60)
                    seg.raise_for_status()
                    f.write(seg.content)
                    break
                except requests.RequestException:
                    if attempt == 2:
                        raise
    # Remux to a clean MP4 (stream copy, seconds even for hours of 160p).
    subprocess.run(["ffmpeg", "-nostdin", "-v", "error", "-y", "-i", part, "-c", "copy",
                    "-movflags", "+faststart", out], check=True, timeout=3600)
    os.remove(part)
    return {"path": out, "offset": round(start - picked[0][0], 3), "duration": round(end - start, 3),
            "segments": len(picked)}


if __name__ == "__main__":
    if len(sys.argv) < 5:
        print(json.dumps({"error": "usage: twitch_section.py <vod_url> <start> <end> <out.mp4> [max_height]"}))
        sys.exit(1)
    try:
        res = fetch_section(sys.argv[1], float(sys.argv[2]), float(sys.argv[3]), sys.argv[4],
                            int(sys.argv[5]) if len(sys.argv) > 5 else 1080)
    except Exception as e:  # noqa: BLE001
        print(json.dumps({"error": str(e)}))
        sys.exit(1)
    print(json.dumps(res))
