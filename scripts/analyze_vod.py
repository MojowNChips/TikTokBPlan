#!/usr/bin/env python3
"""
VOD Analyzer - Finds high-engagement moments in Twitch VODs
Uses chat logs, viewer counts, and audio analysis to score clips
"""

import json
import sys
import os
import subprocess
import re
from datetime import datetime, timedelta
from typing import List, Dict, Any

# Add parent directory to path for imports
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

def get_vod_chat(vod_id: str, client_id: str, access_token: str) -> List[Dict]:
    """Fetch chat logs for a VOD (requires Twitch API with proper scopes)"""
    # Note: Twitch removed public chat replay API
    # Alternative: Use third-party logs or skip chat analysis
    return []

def get_vod_metadata(vod_id: str, client_id: str, access_token: str) -> Dict:
    """Fetch VOD metadata from Twitch API"""
    import requests
    headers = {
        'Client-ID': client_id,
        'Authorization': f'Bearer {access_token}'
    }
    resp = requests.get(f'https://api.twitch.tv/helix/videos?id={vod_id}', headers=headers)
    if resp.status_code == 200:
        data = resp.json().get('data', [])
        return data[0] if data else {}
    return {}

def analyze_audio_energy(video_path: str, start: float, end: float) -> float:
    """Analyze audio energy in a segment using ffmpeg"""
    try:
        cmd = [
            'ffmpeg', '-y', '-i', video_path,
            '-ss', str(start), '-to', str(end),
            '-af', 'astats=metadata=1:reset=1', '-f', 'null', '-'
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        # Parse RMS level from output
        for line in result.stderr.split('\n'):
            if 'RMS level' in line:
                # Extract dB value
                match = re.search(r'RMS level:\s*(-?\d+\.?\d*)', line)
                if match:
                    db = float(match.group(1))
                    # Convert to 0-100 scale (-60dB to 0dB)
                    return max(0, min(100, (db + 60) / 60 * 100))
    except Exception as e:
        print(f"Audio analysis error: {e}", file=sys.stderr)
    return 50  # Default middle score

def detect_visual_changes(video_path: str, start: float, end: float) -> float:
    """Detect scene changes/motion using ffmpeg"""
    try:
        cmd = [
            'ffmpeg', '-y', '-i', video_path,
            '-ss', str(start), '-to', str(end),
            '-vf', 'select=gt(scene\\,0.3),metadata=print:file=-', '-f', 'null', '-'
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=30)
        scene_changes = result.stdout.count('scene_score')
        duration = end - start
        # Normalize: 0-10 changes per minute = 0-100
        return min(100, (scene_changes / (duration / 60)) * 10)
    except Exception as e:
        print(f"Visual analysis error: {e}", file=sys.stderr)
    return 50

def transcribe_segment(video_path: str, start: float, end: float, model_path: str) -> str:
    """Transcribe audio segment using whisper.cpp"""
    try:
        # Extract audio segment
        audio_path = f"/tmp/segment_{start}_{end}.wav"
        cmd = [
            'ffmpeg', '-y', '-i', video_path,
            '-ss', str(start), '-to', str(end),
            '-ar', '16000', '-ac', '1', audio_path
        ]
        subprocess.run(cmd, check=True, capture_output=True, timeout=30)

        # Run whisper.cpp
        cmd = [
            'whisper-cli', '-m', model_path,
            '-f', audio_path, '-otxt'
        ]
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=60)

        # Cleanup
        os.remove(audio_path)
        txt_file = audio_path.replace('.wav', '.txt')
        if os.path.exists(txt_file):
            with open(txt_file, 'r') as f:
                text = f.read()
            os.remove(txt_file)
            return text.strip()
    except Exception as e:
        print(f"Transcription error: {e}", file=sys.stderr)
    return ""

def score_moment(
    start: float, end: float,
    chat_velocity: float,  # messages per second
    peak_viewers: int,
    audio_energy: float,
    visual_changes: float,
    transcript: str,
    keywords: List[str]
) -> Dict[str, Any]:
    """Score a moment based on multiple factors"""

    # Base scores (0-100 each)
    scores = {
        'chat_velocity': min(100, chat_velocity * 10),  # 10 msg/s = 100
        'peak_viewers': min(100, peak_viewers / 100),   # 10k viewers = 100
        'audio_energy': audio_energy,                    # 0-100
        'visual_changes': visual_changes,                # 0-100
        'keywords': 0
    }

    # Keyword bonus
    text_lower = transcript.lower()
    keyword_hits = sum(1 for kw in keywords if kw.lower() in text_lower)
    scores['keywords'] = min(100, keyword_hits * 20)

    # Weighted total
    weights = {
        'chat_velocity': 0.25,
        'peak_viewers': 0.20,
        'audio_energy': 0.15,
        'visual_changes': 0.20,
        'keywords': 0.20
    }

    total_score = sum(scores[k] * weights[k] for k in scores)

    # Determine reason
    reasons = []
    if scores['chat_velocity'] > 70: reasons.append("chat explosion")
    if scores['peak_viewers'] > 70: reasons.append("peak viewership")
    if scores['audio_energy'] > 70: reasons.append("audio spike")
    if scores['visual_changes'] > 70: reasons.append("high action")
    if scores['keywords'] > 50: reasons.append("keyword triggers")

    return {
        'start_time': start,
        'end_time': end,
        'duration': end - start,
        'score': round(total_score),
        'breakdown': scores,
        'reason': ', '.join(reasons) if reasons else 'moderate engagement',
        'transcript': transcript[:200]
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
    min_score: int = 65
) -> List[Dict]:
    """Analyze VOD and return best moments"""

    # High-value keywords for gaming clips
    keywords = [
        'clutch', 'insane', 'crazy', 'unbelievable', 'impossible',
        'one tap', 'headshot', 'ace', 'quad', 'penta', 'team wipe',
        'wtf', 'omg', 'no way', 'lucky', 'hack', 'cheat',
        'funny', 'fail', 'rage', 'tilt', 'throw', 'mistake',
        'react', 'reaction', 'shocked', 'surprised', 'speechless'
    ]

    moments = []

    # For now, simulate analysis without actual video download
    # In production, download VOD first with yt-dlp
    print(f"Analyzing VOD {vod_id} ({duration}s)...", file=sys.stderr)

    # Simulate segments (replace with real analysis)
    # This is a placeholder - real implementation downloads and analyzes
    num_segments = int(duration / stride)

    for i in range(min(num_segments, 100)):  # Limit for demo
        start = i * stride
        end = min(start + segment_length, duration)

        # Simulated scores (replace with real analysis)
        import random
        chat_vel = random.random() * 5
        peak_v = random.randint(100, 50000)
        audio_e = random.random() * 100
        visual_c = random.random() * 100
        transcript = "simulated transcript with clutch moment"

        scored = score_moment(
            start, end, chat_vel, peak_v, audio_e, visual_c, transcript, keywords
        )

        if scored['score'] >= min_score:
            scored['vod_id'] = vod_id
            scored['streamer'] = streamer
            scored['clip_id'] = f"clip_{vod_id}_{int(start)}"
            moments.append(scored)

    # Sort by score descending
    moments.sort(key=lambda x: x['score'], reverse=True)

    # Merge overlapping moments
    merged = []
    for m in moments:
        overlap = False
        for existing in merged:
            if not (m['end_time'] <= existing['start_time'] or m['start_time'] >= existing['end_time']):
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
    client_id = os.getenv('TWITCH_CLIENT_ID')
    access_token = os.getenv('TWITCH_ACCESS_TOKEN')
    model_path = os.getenv('WHISPER_MODEL', '/models/ggml-base.en.bin')

    if not client_id or not access_token:
        print(json.dumps({"error": "Missing Twitch credentials"}))
        sys.exit(1)

    # Get VOD metadata
    metadata = get_vod_metadata(vod_id, client_id, access_token)
    duration_str = metadata.get('duration', '0h0m0s')

    # Parse duration (format: 1h30m45s)
    duration = 0
    for part in duration_str:
        if 'h' in part:
            duration += int(part.replace('h', '')) * 3600
        elif 'm' in part:
            duration += int(part.replace('m', '')) * 60
        elif 's' in part:
            duration += int(part.replace('s', ''))

    # For demo, use a default duration
    if duration == 0:
        duration = 7200  # 2 hours default

    # In production: download VOD first
    # video_path = download_vod(vod_id)
    video_path = f"/temp/{vod_id}.mp4"  # Placeholder

    # Analyze
    moments = find_best_moments(
        vod_id, streamer, video_path, duration,
        client_id, access_token, model_path
    )

    # Output JSON for n8n
    print(json.dumps(moments))

if __name__ == '__main__':
    main()