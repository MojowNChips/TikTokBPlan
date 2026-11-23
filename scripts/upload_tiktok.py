#!/usr/bin/env python3
"""
TikTok Video Kit chunked uploader.
Usage: upload_tiktok.py <video_path> <upload_url> <publish_id>

Performs a single PUT upload to the TikTok upload_url returned by
POST /v2/post/publish/video/init/ and exits 0 on success.
"""

import json
import sys
import os
import requests


def main():
    if len(sys.argv) < 4:
        print(json.dumps({"error": "Usage: upload_tiktok.py <video_path> <upload_url> <publish_id>"}))
        sys.exit(1)

    video_path = sys.argv[1]
    upload_url = sys.argv[2]
    publish_id = sys.argv[3]

    if not os.path.exists(video_path):
        print(json.dumps({"error": f"Video file not found: {video_path}"}))
        sys.exit(1)

    file_size = os.path.getsize(video_path)
    headers = {
        "Content-Type": "video/mp4",
        "Content-Range": f"bytes 0-{file_size - 1}/{file_size}",
    }

    try:
        with open(video_path, "rb") as f:
            resp = requests.put(upload_url, data=f, headers=headers, timeout=600)
        if resp.status_code in (200, 201):
            print(json.dumps({"publish_id": publish_id, "status": "uploaded", "bytes": file_size}))
            sys.exit(0)
        else:
            print(json.dumps({"error": f"Upload failed: {resp.status_code} {resp.text}", "publish_id": publish_id}))
            sys.exit(1)
    except Exception as e:
        print(json.dumps({"error": str(e), "publish_id": publish_id}))
        sys.exit(1)


if __name__ == "__main__":
    main()