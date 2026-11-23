# Custom n8n image with FFmpeg + Python + Whisper pre-installed
# Build once, run many times — no fragile apt/apk at container startup
FROM n8nio/n8n:latest

USER root

# Install system packages (FFmpeg, Python, pip, build tools)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    python3 \
    python3-pip \
    build-essential \
    ca-certificates \
    wget \
    && rm -rf /var/lib/apt/lists/*

# Install Whisper for local transcription
RUN pip3 install --break-system-packages openai-whisper

USER node
