# Custom n8n image with FFmpeg + Python + Whisper pre-installed
# Build once, run many times — no fragile apt/apk at container startup
FROM n8nio/n8n:latest

USER root

# Install system packages (FFmpeg, Python, pip, build tools)
RUN apk add --no-cache ffmpeg python3 py3-pip build-base ca-certificates wget

# Install Whisper for local transcription
RUN pip3 install --break-system-packages openai-whisper

USER node
