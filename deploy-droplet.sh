#!/usr/bin/env bash
# ==============================================================================
# TikTok Clips Automation — DigitalOcean Droplet Setup (All-in-One VPS)
#
# Run this ON your droplet as root:
#   ssh root@<droplet-ip>
#   export DOMAIN=your-domain.com
#   export CADDY_EMAIL=your-real-email@example.com
#   export N8N_PASSWORD=<secure-password>
#   bash /opt/tiktok-clips/deploy-droplet.sh
#
# BEFORE running, copy project files to the droplet from your LOCAL machine:
#   scp -r "D:\Tiktok Buisness plan\*" root@<droplet-ip>:/opt/tiktok-clips/
# ==============================================================================
set -euo pipefail

# --- Configuration ------------------------------------------------------------
DOMAIN="${DOMAIN:-}"
CADDY_EMAIL="${CADDY_EMAIL:-}"
N8N_PASSWORD="${N8N_PASSWORD:-changeme123}"

echo "========================================================"
echo " TikTok Clips Automation — Droplet Setup"
echo " Domain:    ${DOMAIN:-<not set>}"
echo " Email:     ${CADDY_EMAIL:-<not set>}"
echo "========================================================"

# --- 0. Sanity checks --------------------------------------------------------
if [ "$EUID" -ne 0 ]; then
  echo "ERROR: Please run as root (use sudo)."
  exit 1
fi

if [ -z "$DOMAIN" ]; then
  echo "ERROR: Set the DOMAIN environment variable before running."
  echo "Example: export DOMAIN=mydomain.com && bash $0"
  exit 1
fi

if [ -z "$CADDY_EMAIL" ]; then
  echo "ERROR: Set the CADDY_EMAIL environment variable (required for Let's Encrypt)."
  echo "Example: export CADDY_EMAIL=admin@mydomain.com && bash $0"
  exit 1
fi

# --- 1. System packages ------------------------------------------------------
echo "[1/8] Updating system and installing Docker..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -y
apt-get upgrade -y

# Docker
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com | sh
fi
apt-get install -y docker-compose-plugin imagemagick wget ca-certificates dnsutils

# --- 2. Firewall -------------------------------------------------------------
echo "[2/8] Configuring firewall (ufw)..."
apt-get install -y ufw
ufw allow 22/tcp   || true
ufw allow 80/tcp   || true
ufw allow 443/tcp  || true
ufw --force enable

echo "   NOTE: Also add inbound rules for TCP 22/80/443 in DigitalOcean control panel"
echo "   → Networking → Firewalls → [your firewall] → Add rules"

# --- 3. Project directory ----------------------------------------------------
# Your files live at /opt/tiktok-clips/TikTokBPlan on the droplet
PROJECT_DIR="/opt/tiktok-clips/TikTokBPlan"
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

if [ ! -f "$PROJECT_DIR/docker-compose.yml" ]; then
  echo "ERROR: Project files not found in $PROJECT_DIR"
  echo "   Copy them from your local machine first:"
  echo "     scp -r \"D:\\Tiktok Buisness plan\\*\" root@$(hostname -I | awk '{print $1}'):/opt/tiktok-clips/TikTokBPlan/"
  exit 1
fi

# --- 4. Environment file -----------------------------------------------------
echo "[3/8] Writing .env ..."
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

# --- 5. Whisper model --------------------------------------------------------
echo "[4/8] Downloading Whisper model..."
mkdir -p models
wget -q -P models https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin || \
  echo "WARNING: Whisper model download failed (check network)."

# --- 6. Watermark ------------------------------------------------------------
echo "[5/8] Converting watermark SVG to PNG..."
if [ -f scripts/assets/watermark.svg ]; then
  convert scripts/assets/watermark.svg -background transparent scripts/assets/watermark.png || \
    echo "WARNING: ImageMagick convert failed."
fi

# --- 7. DNS pre-flight check -------------------------------------------------
echo "[6/8] Waiting for DNS to resolve $DOMAIN to this droplet..."
DROPLET_IP=$(hostname -I | awk '{print $1}')
RESOLVED=""
for i in $(seq 1 30); do
  RESOLVED=$(dig +short "$DOMAIN" | head -1)
  if [ "$RESOLVED" = "$DROPLET_IP" ]; then
    echo "   DNS confirmed: $DOMAIN -> $DROPLET_IP"
    break
  fi
  echo "   Attempt $i/30: $DOMAIN resolves to '$RESOLVED' (expected $DROPLET_IP)... waiting 10s"
  sleep 10
done

if [ "$RESOLVED" != "$DROPLET_IP" ]; then
  echo "WARNING: DNS has not propagated yet. Caddy may fail to issue SSL until it does."
  echo "   You can re-run this script after DNS resolves, or manually trigger Caddy renewal."
fi

# --- 8. Caddyfile render + Launch --------------------------------------------
echo "[7/8] Rendering Caddyfile..."
sed -e "s|\${YOUR_DOMAIN}|$DOMAIN|g" \
    -e "s|\${CADDY_EMAIL}|$CADDY_EMAIL|g" \
    Caddyfile > Caddyfile.rendered

# Fix: Remove header_down * which strips Content-Type headers
# This was causing "MIME type error" for JS module files
sed -i '/header_down/d' Caddyfile.rendered

# Add transport http config for large buffers (using a temp file)
if ! grep -q "transport http" Caddyfile.rendered; then
    awk '/header_up X-Forwarded-Port {server_port}/{
        print
        print "            transport http {"
        print "                read_buffer 4MB"
        print "                write_buffer 4MB"
        print "            }"
        next
    }1' Caddyfile.rendered > Caddyfile.rendered.tmp
    mv Caddyfile.rendered.tmp Caddyfile.rendered
fi

cp Caddyfile.rendered Caddyfile

echo "[8/8] Starting containers..."
if ! docker compose up -d; then
  echo "ERROR: docker compose up failed. Recent logs:"
  docker compose logs --tail 50 2>/dev/null || true
  exit 1
fi

echo ""
echo "========================================================"
echo " DONE — Next steps:"
echo " 1. Open https://$DOMAIN   -> n8n UI (admin / $N8N_PASSWORD)"
echo " 2. Fill remaining secrets in /opt/tiktok-clips/.env"
echo " 3. Restart: docker compose restart n8n"
echo " 4. Import 5 workflows from workflows/ into n8n"
echo " 5. Activate workflows 01 -> 05 in order"
echo ""
echo " TikTok review URLs (once DNS + SSL are live):"
echo "   https://$DOMAIN/privacy"
echo "   https://$DOMAIN/terms"
echo "   https://$DOMAIN/data-usage"
echo "   https://$DOMAIN/app-description"
echo ""
echo " Verify containers:"
echo "   docker ps"
echo "   ss -tlnp | grep -E ':80|:443'"
echo "   docker logs tiktok-clips-caddy --tail 30"
echo "========================================================"
