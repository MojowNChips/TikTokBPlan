# TikTok Streamer Clips - Automated 30-Day Monetization System

> **Complete n8n-based automation pipeline** for fetching, analyzing, editing, and posting streamer clips to TikTok. Built for **$0-15/month** using open-source tools.

## 🎯 Goal
Reach **TikTok Creator Rewards** (10k followers, 100k views in 30 days) with a fully automated clip pipeline.

## ⚠️ Legal Warning - READ FIRST

**Using public Twitch/Kick VODs without permission risks:**
- TikTok demonetization (fails "Original Content" policy)
- DMCA copyright strikes
- Account bans

**You MUST choose one compliant approach:**
1. ✅ **Partner with streamers** - Written permission + VOD access (RECOMMENDED)
2. ✅ **Use only clips.twitch.tv** - Streamers' own curated public clips
3. ✅ **Add transformative commentary** - Voiceover, analysis, educational value
4. ❌ **Raw public VODs** - Will likely fail monetization review

This system builds the automation. **YOU decide the legal path.**

---

## 🏗️ Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  FETCH      │────▶│  ANALYZE    │────▶│  PROCESS    │────▶│  POST       │
│  (Twitch/   │     │  (Score +   │     │  (FFmpeg +  │     │  (TikTok    │
│   Kick API) │     │  Transcribe)│     │  Captions)  │     │   API)      │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
       │                   │                   │                   │
  - VOD list           - Whisper.cpp         - Crop 9:16       - Schedule
  - Chat logs          - Keyword match       - Burn captions   - Hashtags
  - Metadata           - Visual analysis     - Watermark       - Caption
                       - Scoring             - Compress        - Thumbnail
```

---

## 📁 Project Structure

```
Tiktok Buisness plan/
├── README.md                    # This file
├── TIKTOK_30DAY_PLAN.md         # Complete 30-day strategy
├── QUICKSTART_CHECKLIST.md      # Day-by-day launch checklist
├── DEPLOYMENT_GUIDE.md          # Full VPS deployment guide
├── GOOGLE_SHEETS_TEMPLATE.md    # Sheets schema & setup
├── docker-compose.yml           # n8n + FFmpeg + Whisper + Redis
├── .env.example                 # Environment variables template
├── workflows/                   # 5 n8n workflows (import in order)
│   ├── 01_daily_vod_fetch.json
│   ├── 02_clip_analyzer.json
│   ├── 03_video_processor.json
│   ├── 04_tiktok_publisher.json
│   └── 05_analytics_collector.json
└── scripts/
    ├── analyze_vod.py           # VOD moment detection & scoring
    ├── process_clip_wrapper.py  # Bridge to existing auto_edit_clips.py
    └── assets/
        └── watermark.svg        # Brand watermark
```

---

## 🚀 Quick Start

### 1. Prerequisites
- **VPS** ($5/mo): Hetzner CX22, DigitalOcean $6, Linode $5
- **APIs**: Twitch Dev, TikTok Developer, Google Cloud, Discord, Cloudflare R2
- **Domain** (optional): For SSL + professional webhooks

### 2. Deploy (5 minutes on VPS)
```bash
# On your VPS
ssh root@your-vps-ip
curl -fsSL https://get.docker.com | sh
apt install docker-compose-plugin -y

mkdir -p /opt/tiktok-clips && cd /opt/tiktok-clips
# Copy all files from this folder to VPS

cp .env.example .env
nano .env  # Fill in ALL credentials

mkdir -p models
wget -P models https://huggingface.co/ggerganov/whisper.cpp/resolve/main/ggml-base.en.bin

apt install imagemagick -y
convert scripts/assets/watermark.svg -background transparent scripts/assets/watermark.png

docker compose up -d
```

### 3. Configure n8n
1. Open `http://your-vps-ip:5678`
2. Login: `admin` / `your_password`
3. Import 5 workflows from `workflows/` (Settings → Workflows → Import)
4. Add credentials: Google Sheets, Twitch, TikTok, Discord
5. Activate all workflows (01→02→03→04→05)

### 4. Test
```bash
# Trigger VOD fetch manually
curl -X POST http://localhost:5678/webhook/analyze-vod \
  -H "Content-Type: application/json" \
  -d '{"vod_id": "123456789", "streamer": "shroud", ...}'
```

---

## 💰 Cost Breakdown

| Component | Monthly Cost |
|-----------|-------------|
| VPS (2 vCPU, 4GB RAM) | $5-6 |
| Cloudflare R2 (100GB) | $1-2 |
| Domain (optional) | $1 |
| **Total** | **~$8/month** |

All software: **Free & Open Source** (n8n, FFmpeg, Whisper.cpp, Python)

---

## 📊 30-Day Phases

| Phase | Days | Target | Focus |
|-------|------|--------|-------|
| **Foundation** | 1-7 | 1k followers, 10k views | 3 pillars, 3-5 clips/day, baseline |
| **Optimization** | 8-14 | 3k followers, 50k views | A/B test, double down on winners |
| **Scale** | 15-21 | 6k followers, 100k views | Cross-post, series, smart scheduling |
| **Monetize** | 22-30 | 10k+ followers, 100k+ views | Viral attempts, collabs, giveaway |

---

## 🔧 Tech Stack

| Layer | Tool | Why |
|-------|------|-----|
| Automation | n8n (self-hosted) | Free, visual, extensible, 400+ integrations |
| Video | FFmpeg | Industry standard, hardware acceleration |
| Transcription | Whisper.cpp | Local, free, fast, no API costs |
| Scoring | Custom Python | Multi-factor: chat, audio, visual, keywords |
| Storage | Cloudflare R2 | S3-compatible, free egress, $0.015/GB |
| Analytics | Google Sheets | Free, real-time, shareable, formula support |
| Monitoring | Uptime Kuma | Free, self-hosted, beautiful dashboards |

---

## 📈 Key Features

- **Smart Clip Selection**: Multi-factor scoring (chat velocity, audio spikes, visual changes, keywords)
- **Auto-Captions**: Whisper.cpp local transcription, burned into video
- **Vertical Crop**: Auto 9:16 with smart center-crop
- **Branding**: Watermark + streamer handle + clip title overlay
- **Scheduled Posting**: 4x/day at optimal times (11am, 3pm, 7pm, 10pm EST)
- **Analytics**: Hourly TikTok stats → Google Sheets with viral alerts
- **Notifications**: Discord webhooks for new clips, posts, viral hits
- **Deduplication**: Prevents re-posting same moments
- **Cross-Platform Ready**: Same pipeline works for YouTube Shorts / Reels

---

## 🛡️ Risk Mitigation

| Risk | Mitigation |
|------|------------|
| TikTok API limits | Queue + exponential backoff + multiple apps |
| Copyright strikes | Permission system, transformative edits, music detection |
| Low clip quality | Score threshold (65+), human review gate |
| VPS downtime | Backup VPS, local n8n ready, Uptime Kuma alerts |
| Algorithm changes | Diversify platforms, build email list |
| Burnout | Fully automated, batch review weekly |

---

## 📋 Next Steps for You

1. **Choose legal approach** (partner / clips.twitch.tv / commentary)
2. **Provision VPS** (Hetzner recommended)
3. **Register APIs** (Twitch, TikTok, Google, Discord, R2)
4. **Deploy using DEPLOYMENT_GUIDE.md**
5. **Follow QUICKSTART_CHECKLIST.md** day by day

---

## 📚 Documentation

| File | Purpose |
|------|---------|
| `TIKTOK_30DAY_PLAN.md` | Complete strategy, scoring algorithm, phases |
| `DEPLOYMENT_GUIDE.md` | Step-by-step VPS deployment |
| `QUICKSTART_CHECKLIST.md` | Daily/weekly action items |
| `GOOGLE_SHEETS_TEMPLATE.md` | Schema, formulas, service account setup |

---

## 🤝 Contributing

This is a personal automation system. Fork and adapt for your needs.

---

## ⚖️ License

MIT - Use freely. **You are responsible for legal compliance** with your clip sources.

---

*Built with n8n, FFmpeg, Whisper.cpp, and Python | 2026*