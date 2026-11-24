# TikTok Streamer Clips — Automation

n8n pipeline: Twitch VOD → best moments → vertical captioned clip → TikTok, 4×/day, with stats back in Google Sheets.

- **How to install & use:** [GUIDE.md](GUIDE.md) (also `GUIDE.pdf`)
- **Growth & money plan:** [30_DAY_PLAN.md](30_DAY_PLAN.md) (also `30_DAY_PLAN.pdf`)
- **TikTok app review texts:** [TikTokAPI_review/REVIEW_PACK.md](TikTokAPI_review/REVIEW_PACK.md)

Quick deploy on the droplet:
```bash
git clone https://github.com/MojowNChips/TikTokBPlan.git /opt/tiktok-clips/TikTokBPlan
cd /opt/tiktok-clips/TikTokBPlan
DOMAIN=your.domain CADDY_EMAIL=you@mail.com bash deploy-droplet.sh
```
Health check: `bash diagnose.sh`

MIT licence — you are responsible for having the rights to the clips you post.
