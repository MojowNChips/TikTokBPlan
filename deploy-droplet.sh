#!/usr/bin/env bash
# ==============================================================================
# TikTok Clips Automation — DigitalOcean Droplet Setup (All-in-One VPS)
#
# Run this ON your droplet as root:
#   ssh root@<droplet-ip>
#   curl -fsSL https://raw.githubusercontent.com/<you>/<repo>/main/deploy-droplet.sh | sudo bash
#
# Or copy this file to the droplet and run:  bash deploy-droplet.sh
# ==============================================================================
set -euo pipefail

# --- Configuration ------------------------------------------------------------
# Override these via environment variables before running:
DOMAIN="${DOMAIN:-your-domain.com}"       # <-- CHANGE ME: your domain pointing at this droplet
CADDY_EMAIL="${CADDY_EMAIL:-admin@your-domain.com}"   # for Let's Encrypt
N8N_PASSWORD="${N8N_PASSWORD:-changeme123}"           # <-- CHANGE ME: secure n8n login

echo "========================================================"
echo " TikTok Clips Automation — Droplet Setup"
echo " Domain:    $DOMAIN"
echo " Email:     $CADDY_EMAIL"
echo "========================================================"

# --- 0. Sanity checks --------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Please run as root (use sudo)."
  exit 1
fi

if [ "$DOMAIN" = "your-domain.com" ]; then
  echo "ERROR: Set the DOMAIN environment variable before running."
  echo "Example: export DOMAIN=mydomain.com && bash $0"
  exit 1
fi

# --- 1. System packages ------------------------------------------------------
echo "[1/7] Updating system and installing Docker..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Docker
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi
apt-get install -y docker-compose-plugin imagemagick wget ca-certificates

# --- 2. Project directory ----------------------------------------------------
PROJECT_DIR="/opt/tiktok-clips"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

echo "[2/7] Copying project files from local machine..."
echo "   Run this on your LOCAL machine (not in this SSH session):"
echo "     scp -r \"D:\\Tiktok Buisness plan\"/* root@$(hostname -I | awk '{print $1}'):/opt/tiktok-clips/"
echo "   Then re-run this script."
echo ""

# If files already exist (e.g. re-run), skip the scp reminder below but continue.
if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
  echo "Project files not found yet. Copy them, then re-run."
  exit 1
fi

# --- 3. Environment file -----------------------------------------------------
echo "[3/7] Writing .env ..."
cat > .env <<EOF
# n8n
N8N_PASSWORD=${N8N_PASSWORD}

# Twitch API (fill these in .env after first run)
TWITCH_CLIENT_ID=
TWITCH_CLIENT_SECRET=
TWITCH_ACCESS_TOKEN=
TWITCH_REFRESH_TOKEN=

# Kick API
KICK_CLIENT_ID=
KICK_CLIENT_SECRET=

# TikTok Developer (fill these after approval)
TIKTOK_CLIENT_KEY=
TIKTOK_CLIENT_SECRET=
TIKTOK_ACCESS_TOKEN=
TIKTOK_REFRESH_TOKEN=

# Google Sheets
GOOGLE_SHEETS_CREDENTIALS_JSON=
GOOGLE_SHEET_ID=

# Discord
DISCORD_WEBHOOK_URL=

# Cloudflare R2
R2_ACCOUNT_ID=
R2_ACCESS_KEY_ID=
R2_SECRET_ACCESS_KEY=
R2_BUCKET_NAME=tiktok-clips
R2_PUBLIC_URL=https://pub-xxx.r2.dev

# OpenAI (optional)
OPENAI_API_KEY=

# Whisper
WHISPER_MODEL=/models/ggml-base.en.bin

# Streamers & Games
STREAMER_LIST=streamer1,streamer2,streamer3
GAME_LIST=Valorant,League of Legends,Counter-Strike 2
EOF

# --- 4. Whisper model --------------------------------------------------------
echo "[4/7] Downloading Whisper model..."
mkdir -p models
wget -q -P models https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin || \
  echo "WARNING: Whisper model download failed (check network)."

# --- 5. Watermark ------------------------------------------------------------
echo "[5/7] Converting watermark SVG to PNG..."
if [ -f scripts/assets/watermark.svg ]; then
  convert scripts/assets/watermark.svg -background transparent scripts/assets/watermark.png || \
    echo "WARNING: ImageMagick convert failed."
fi

# --- 6. Caddyfile (domain + email) -------------------------------------------
echo "[6/7] Generating Caddyfile..."
sed -e "s|\${YOUR_DOMAIN}|$DOMAIN|g" \
    -e "s|\${CADDY_EMAIL}|$CADDY_EMAIL|g" \
    Caddyfile > Caddyfile.rendered
cp Caddyfile.rendered Caddyfile

# --- 7. Launch ---------------------------------------------------------------
echo "[7/7] Starting containers..."
docker compose up -d

echo ""
echo "========================================================"
echo " DONE — Next steps:"
echo " 1. Open https://$DOMAIN   -> n8n UI (admin / $N8N_PASSWORD)"
echo " 2. Fill remaining secrets in /opt/tiktok-clips/.env"
echo " 3. Restart: docker compose restart n8n"
echo " 4. Import 5 workflows from workflows/ into n8n"
echo " 5. Activate workflows 01 -> 05 in order"
echo ""
echo " TikTok review URLs (once DNS points here):"
echo "   https://$DOMAIN/privacy"
echo "   https://$DOMAIN/terms"
echo "   https://$DOMAIN/data-usage"
echo "   https://$DOMAIN/app-description"
echo "========================================================"
