#!/usr/bin/env python3
"""
Wrapper script to use existing auto_edit_clips.py for video processing
This leverages the existing video clipping infrastructure in the project
"""

import sys
import os
import json
import subprocess

# Add the project root to path
PROJECT_ROOT = os.path.dirname(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))
sys.path.insert(0, PROJECT_ROOT)

def process_with_existing_tool(clip_data: dict) -> dict:
    """
    Use the existing auto_edit_clips.py to process clips
    """
    # The existing tool expects different input format
    # This is a bridge - in practice, you'd adapt auto_edit_clips.py
    # or call it as a subprocess with the right arguments

    vod_url = clip_data.get('vod_url')
    start_time = clip_data.get('start_time')
    end_time = clip_data.get('end_time')
    clip_id = clip_data.get('clip_id')
    streamer = clip_data.get('streamer')

    output_path = f"/output/{clip_id}.mp4"

    # Build command for auto_edit_clips.py
    # Note: Check the actual CLI of auto_edit_clips.py
    cmd = [
        sys.executable,
        os.path.join(PROJECT_ROOT, 'auto_edit_clips.py'),
        '--url', vod_url,
        '--start', str(start_time),
        '--end', str(end_time),
        '--output', output_path,
        '--vertical',  # 9:16 for TikTok
        '--captions',  # Burn captions
        '--watermark', f'@{streamer}'
    ]

    try:
        result = subprocess.run(cmd, capture_output=True, text=True, timeout=300)
        if result.returncode == 0:
            return {
                'success': True,
                'output_path': output_path,
                'stdout': result.stdout
            }
        else:
            return {
                'success': False,
                'error': result.stderr
            }
    except subprocess.TimeoutExpired:
        return {'success': False, 'error': 'Processing timeout'}
    except Exception as e:
        return {'success': False, 'error': str(e)}

def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "Usage: process_clip_wrapper.py <clip_json>"}))
        sys.exit(1)

    # Read clip data from stdin or file
    try:
        if sys.argv[1] == '-':
            clip_data = json.load(sys.stdin)
        else:
            with open(sys.argv[1], 'r') as f:
                clip_data = json.load(f)
    except (json.JSONDecodeError, FileNotFoundError, IOError) as e:
        print(json.dumps({"error": f"Failed to read clip data: {e}"}))
        sys.exit(1)

    result = process_with_existing_tool(clip_data)
    print(json.dumps(result))

if __name__ == '__main__':
    main()