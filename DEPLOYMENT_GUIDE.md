# Deployment Guide - TikTok Clips Automation

## Prerequisites

### 1. VPS / Server ($5-6/month)
- **Recommended:** Hetzner CX22 (€4.51/mo), DigitalOcean $6, Linode $5
- **Specs:** 2 vCPU, 4GB RAM, 40GB SSD, Ubuntu 22.04
- **Location:** Close to your target audience (US East for US viewers)

### 2. Domain (Optional but recommended)
- Point A record to VPS IP
- Set up Cloudflare for SSL + DDoS protection

---

## Step 1: Server Setup

```bash
# SSH into your VPS
ssh root@your-vps-ip

# Update system
apt update && apt upgrade -y

# Install Docker
curl -fsSL https://get.docker.com | sh

# Install Docker Compose
apt install docker-compose-plugin -y

# Create project directory
mkdir -p /opt/tiktok-clips
cd /opt/tiktok-clips
```

---

## Step 2: Deploy Application

```bash
# Clone or copy your project files
# Option A: Git (if you push to repo)
git clone https://github.com/yourusername/tiktok-clips.git .

# Option B: SCP from local
# scp -r "Tiktok Buisness plan"/* root@your-vps-ip:/opt/tiktok-clips/

# Copy environment file
cp .env.example .env
nano .env  # Fill in ALL values
```

---

## Step 3: Configure .env (REQUIRED)

Fill in every value in `.env`:

```bash
# n8n
N8N_PASSWORD=your_very_secure_password_123

# Twitch API - Create at https://dev.twitch.tv/console/apps
# OAuth Redirect: http://your-domain:5678/rest/oauth2-credential/callback
TWITCH_CLIENT_ID=abc123
TWITCH_CLIENT_SECRET=secret123
TWITCH_ACCESS_TOKEN=token123  # Get via OAuth flow
TWITCH_REFRESH_TOKEN=refresh123

# TikTok Developer - Apply at https://developers.tiktok.com/
# Requires: Video Upload, Video Query, User Info scopes
TIKTOK_CLIENT_KEY=key123
TIKTOK_CLIENT_SECRET=secret123
TIKTOK_ACCESS_TOKEN=token123
TIKTOK_REFRESH_TOKEN=refresh123

# Google Sheets - Service Account JSON (one line!)
GOOGLE_SHEETS_CREDENTIALS_JSON={"type":"service_account",...}
GOOGLE_SHEET_ID=1abc123...

# Discord Webhook - Create in Discord Server Settings → Integrations
DISCORD_WEBHOOK_URL=https://discord.com/api/webhooks/xxx/yyy

# Cloudflare R2 (or AWS S3) - For video storage
# Create bucket, get API token
R2_ACCOUNT_ID=account123
R2_ACCESS_KEY_ID=key123
R2_SECRET_ACCESS_KEY=secret123
R2_BUCKET_NAME=tiktok-clips
R2_PUBLIC_URL=https://pub-xxx.r2.dev

# Streamers & Games
STREAMER_LIST=shroud,ninja,pokimane,xqc,hasanabi
GAME_LIST=Valorant,League of Legends,Counter-Strike 2,Fortnite,Apex Legends
```

---

## Step 4: Get API Credentials

### Twitch API
1. Go to https://dev.twitch.tv/console/apps
2. Register Application:
   - Name: "TikTok Clips Bot"
   - OAuth Redirect: `http://your-domain:5678/rest/oauth2-credential/callback`
   - Category: "Application Integration"
3. Copy Client ID & Secret
4. Get tokens via OAuth:
   ```
   https://id.twitch.tv/oauth2/authorize?
     client_id=YOUR_CLIENT_ID&
     redirect_uri=http://your-domain:5678/rest/oauth2-credential/callback&
     response_type=code&
     scope=analytics:read:extensions+user:read:email+clips:edit
   ```
5. Exchange code for tokens

### TikTok Developer
1. Apply at https://developers.tiktok.com/
2. Create "Login Kit" + "Video Kit" app
3. Request scopes: `video.upload`, `video.list`, `user.info.basic`
4. Wait for approval (1-3 days)
5. Get tokens via OAuth

### Google Sheets
1. Follow GOOGLE_SHEETS_TEMPLATE.md
2. Create service account, enable APIs
3. Share sheet with service account email
4. Paste JSON as ONE LINE in .env

---

## Step 5: Download Whisper Model

```bash
# On VPS
mkdir -p /opt/tiktok-clips/models
cd /opt/tiktok-clips/models

# Download base English model (~150MB)
wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin

# Or larger model for better accuracy (~1.5GB)
# wget https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-large-v3.bin
```

---

## Step 6: Create Watermark Image

```bash
# Convert SVG to PNG (install imagemagick first)
apt install imagemagick -y
cd /opt/tiktok-clips/scripts/assets
convert watermark.svg -background transparent watermark.png

# Verify
ls -la watermark.png
```

---

## Step 7: Launch

```bash
cd /opt/tiktok-clips

# Pull images and start
docker compose pull
docker compose up -d

# Check logs
docker compose logs -f n8n
```

---

## Step 8: Configure n8n

1. Open `http://your-vps-ip:5678`
2. Login: `admin` / `your_password_from_env`
3. **Import Workflows:**
   - Settings → Workflows → Import
   - Import all 5 JSON files from `workflows/` folder
4. **Configure Credentials:**
   - Settings → Credentials → New Credential
   - Add: Google Sheets OAuth2 API, Twitch API, TikTok API, Discord Webhook
5. **Activate Workflows:**
   - Open each workflow → Click "Activate" toggle
   - Order: 01 → 02 → 03 → 04 → 05

---

## Step 9: Test Pipeline

```bash
# Test VOD fetch (trigger manually)
curl -X POST http://localhost:5678/webhook/analyze-vod \
  -H "Content-Type: application/json" \
  -d '{"vod_id": "123456789", "streamer": "shroud", "title": "Test", "game": "Valorant", "duration": 7200, "url": "https://twitch.tv/videos/123456789", "created_at": "2024-01-15T20:00:00Z", "view_count": 50000}'

# Check n8n executions for results
```

---

## Step 10: Set Up Monitoring

```bash
# Uptime Kuma
# Open http://your-vps-ip:3001
# Create account, add monitors:
# - n8n: http://localhost:5678/healthz
# - Each webhook endpoint

# Optional: Log rotation
cat > /etc/logrotate.d/tiktok-clips << 'EOF'
/opt/tiktok-clips/logs/*.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
EOF
```

---

## Step 11: SSL with Cloudflare (Recommended)

1. Add domain to Cloudflare
2. Set DNS: A record → VPS IP (Proxied ON)
3. SSL/TLS → Full (Strict)
4. Create Origin Certificate in Cloudflare
5. Update docker-compose.yml with SSL certs
6. Restart: `docker compose restart n8n`

---

## Maintenance

### Daily (Automated)
- VOD fetch runs at 2 AM
- Clips post at 11 AM, 3 PM, 7 PM, 10 PM EST
- Analytics update hourly

### Weekly
```bash
# Check disk space
df -h

# Clean old temp files
docker exec tiktok-clips-n8n find /temp -mtime +3 -delete

# Update n8n (monthly)
docker compose pull && docker compose up -d
```

### Troubleshooting

| Issue | Solution |
|-------|----------|
| n8n won't start | Check `.env` values, `docker compose logs n8n` |
| TikTok upload fails | Verify token not expired, check file size < 500MB |
| Whisper slow | Use smaller model, or enable GPU |
| Google Sheets 403 | Re-share sheet with service account |
| VOD download fails | Check yt-dlp version, Twitch may block |

---

## Cost Breakdown

| Item | Monthly Cost |
|------|-------------|
| VPS (Hetzner CX22) | €4.51 (~$5) |
| Cloudflare R2 (100GB) | ~$1.50 |
| Domain (optional) | ~$1 |
| **Total** | **~$7.50/month** |

---

## Scaling Tips

1. **More clips:** Add more streamers to `STREAMER_LIST`
2. **Faster processing:** Upgrade VPS to 4 vCPU / 8GB RAM
3. **Multiple accounts:** Duplicate workflows with different TikTok credentials
4. **Cross-post:** Add YouTube Shorts / Reels workflows (same pattern)

---

## Legal Compliance Checklist

- [ ] Written permission from each streamer OR
- [ ] Only use clips.twitch.tv public clips OR
- [ ] Add transformative commentary (voiceover, analysis)
- [ ] No copyrighted music in clips (game audio OK)
- [ ] TikTok "Original Content" policy met
- [ ] Brand-safe streamers only
- [ ] DMCA process documented

---

## Support

- n8n Docs: https://docs.n8n.io/
- Twitch API: https://dev.twitch.tv/docs/api/
- TikTok API: https://developers.tiktok.com/doc/login-kit-web/
- Whisper.cpp: https://github.com/ggerganov/whisper.cpp