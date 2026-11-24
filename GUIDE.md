# TikTok Clips Automation — How to Use It

*One guide for everything: setup, deploy, daily use, fixes. Replaces README / DEPLOYMENT_GUIDE / QUICKSTART_CHECKLIST / GOOGLE_SHEETS_TEMPLATE.*

---

## 1. What it does

Twitch VOD → finds the best moments → cuts a vertical clip with burned captions + watermark → posts to TikTok 4×/day → pulls stats back every hour. Everything runs in **n8n** on one droplet.

```
01 FETCH  (02:00)        Twitch API      -> VOD_Queue
   |
02 ANALYZE               analyze_vod.py  -> Clip_Queue  + Discord
   |
03 RENDER                ffmpeg+whisper  -> Ready_Clips (+ R2)
   |
04 POST   (11/15/19/22h) TikTok API      -> Analytics
   |
05 STATS  (hourly)       TikTok API      -> Analytics   + viral alert
```

| # | Workflow | Trigger | Does |
|---|----------|---------|------|
| 01 | Daily VOD Fetch | cron `0 2 * * *` | Gets new VODs for `STREAMER_LIST`, logs them, calls 02 for each |
| 02 | Clip Analyzer | called by 01, or webhook `POST /webhook/analyze-vod` | Runs `scripts/analyze_vod.py` (loudness + scene cuts + keywords), keeps clips with score ≥ `CLIP_SCORE_THRESHOLD` (max `MAX_CLIPS_PER_VOD`), Discord ping, calls 03 |
| 03 | Video Processor | called by 02, or webhook `POST /webhook/process-clip` | Downloads the section, whisper captions, 9:16 crop + watermark, optional R2 upload, row in `Ready_Clips` |
| 04 | TikTok Publisher | cron `0 11,15,19,22 * * *` | Takes first `ready_to_post` row, writes caption + hashtags, uploads, marks `posted` |
| 05 | Analytics Collector | cron `0 * * * *` | Views/likes/shares into `Analytics`, Discord alert on viral clips |

All times are **America/New_York** (set in `docker-compose.yml`).

---

## 2. Folder map

```
Tiktok Buisness plan/
├── GUIDE.md / GUIDE.pdf              ← this file
├── 30_DAY_PLAN.md / 30_DAY_PLAN.pdf  ← growth + monetization plan
├── README.md                         ← short pointer
├── docker-compose.yml   Dockerfile   Caddyfile   .env.example
├── deploy-droplet.sh                 ← one-shot install on the droplet (safe to re-run)
├── diagnose.sh                       ← read-only health check on the droplet
├── workflows/01..05_*.json           ← import into n8n
├── scripts/analyze_vod.py            ← moment detection + scoring
├── scripts/twitch_section.py         ← downloads only the needed part of a VOD (used by 02 + 03)
├── scripts/upload_tiktok.py          ← TikTok file upload
├── scripts/assets/watermark.svg
└── TikTokAPI_review/                 ← pages TikTok reviewers read (served at /privacy, /terms…)
    ├── *.html  logo.svg  convert-logo.bat  svg-to-png.js
    └── REVIEW_PACK.md / .pdf         ← all review texts + submission checklist in one file
```

Containers: `n8n` (custom image with ffmpeg, yt-dlp, whisper-cli, python3, aws), `caddy` (HTTPS), `docs` (nginx for legal pages), `uptime-kuma` (monitoring on :3001).

---

## 3. Accounts you need (do these first)

| Service | Where | What to copy into `.env` |
|---------|-------|--------------------------|
| Twitch | dev.twitch.tv/console/apps → Register app | `TWITCH_CLIENT_ID`, `TWITCH_CLIENT_SECRET` (app token is fetched automatically) |
| TikTok | developers.tiktok.com → app with Login Kit + Content Posting API, scopes `video.upload`, `video.publish`, `video.list`, `user.info.basic` | `TIKTOK_CLIENT_KEY`, `TIKTOK_CLIENT_SECRET`, `TIKTOK_ACCESS_TOKEN`, `TIKTOK_REFRESH_TOKEN` |
| Google | console.cloud.google.com → enable Sheets + Drive API → service account → JSON key | `GOOGLE_SHEET_ID` (+ add the credential inside n8n, see §6) |
| Discord | Server settings → Integrations → Webhook | `DISCORD_WEBHOOK_URL` |
| Cloudflare R2 *(optional)* | R2 → bucket + API token | `R2_*` — without it clips stay on the droplet in `./output` |
| Domain | any registrar, **A record → droplet IP** | `DOMAIN`, `CADDY_EMAIL` |

> ⚠️ **TikTok audit = critical path.** Until TikTok audits your app, every API post is **private (SELF_ONLY)**, max 5 users/24 h, and the TikTok account must be set to private. Keep `TIKTOK_PRIVACY_LEVEL=SELF_ONLY` until approved. Submit the audit on day 0 — use `TikTokAPI_review/REVIEW_PACK.pdf`.

### Google Sheet — create these tabs (exact names)

| Tab | Columns (row 1) |
|-----|-----------------|
| `VOD_Queue` | vod_id, streamer, title, game, duration, url, thumbnail, created_at, view_count, status |
| `Clip_Queue` | clip_id, vod_id, streamer, game, start_time, end_time, title, reason, score, status, review_url, created_at |
| `Ready_Clips` | clip_id, vod_id, streamer, game, start_time, end_time, title, reason, score, video_path, video_url, file_size_mb, status, posted_at |
| `Analytics` | posted_at, clip_id, streamer, game, pillar, publish_id, status, views, likes, comments, shares, saves, updated_at |

`status` in `Ready_Clips`: `ready_to_post` → `posted` / `failed` / `skipped`. To skip a clip by hand, type `skipped`.
Share the sheet with the service account `client_email` as **Editor**.

---

## 4. Deploy on the droplet

You get a shell through the **DigitalOcean web console** (Droplet → Access → Launch Droplet Console). Paste commands there.

```bash
# 1. Get the code
git clone https://github.com/MojowNChips/TikTokBPlan.git /opt/tiktok-clips/TikTokBPlan
cd /opt/tiktok-clips/TikTokBPlan

# 2. Install everything (Docker, firewall, whisper model, HTTPS, containers)
export DOMAIN=claudinesclip.online
export CADDY_EMAIL=you@example.com
bash deploy-droplet.sh

# 3. Fill secrets, then restart n8n
nano .env
docker compose up -d --force-recreate n8n
```

`deploy-droplet.sh` is safe to re-run: it **keeps an existing `.env`**, skips the model download if present, and waits for DNS before HTTPS.

Firewall: the script opens 22/80/443 in `ufw`; also allow them in **DigitalOcean → Networking → Firewalls** if you use one.

---

## 5. `.env` cheat sheet

| Variable | Default | Meaning |
|----------|---------|---------|
| `STREAMER_LIST` | — | Twitch logins, comma-separated |
| `GAME_LIST` | — | Only VODs in these games are kept |
| `CLIP_WINDOW` | `30` | Clip length in seconds. **Creator Rewards only pays on videos > 60 s → set `65`+ when you start monetizing** |
| `CLIP_SCORE_THRESHOLD` | `60` | Minimum score 0-100 |
| `MAX_CLIPS_PER_VOD` | `3` | Best N clips kept per VOD |
| `TIKTOK_PRIVACY_LEVEL` | `SELF_ONLY` | `PUBLIC_TO_EVERYONE` only after the TikTok audit |
| `MAX_ANALYZE_SECONDS` | `14400` | Only the first 4 h of a VOD are analyzed |
| `WHISPER_MODEL` | `/models/ggml-base.en.bin` | Bigger model = better captions, slower |

Change a value → `docker compose up -d --force-recreate n8n`.

---

## 6. Set up n8n (first time)

1. Open `https://<DOMAIN>` → create the **owner account** (that is the login; there is no basic-auth password).
2. **Workflows → Import from file** → import `01` … `05` from `workflows/`.
3. **Credentials → New → Google Sheets (Service Account)** → paste the JSON key. Open every Google Sheets node (01, 02, 03, 04, 05) and pick this credential.
4. In workflow 01, open *Analyze Each VOD (02)* and select workflow 02; in 02, *Render Each Clip (03)* → select 03.
5. **Activate** in order 05 → 04 → 03 → 02 → 01.

---

## 7. Test it (one VOD, by hand)

From the droplet console:

```bash
curl -X POST https://<DOMAIN>/webhook/analyze-vod \
  -H "Content-Type: application/json" \
  -d '{"vod_id":"<A_REAL_VOD_ID>","streamer":"<login>","title":"test","game":"Valorant","url":"https://www.twitch.tv/videos/<A_REAL_VOD_ID>"}'
```

Expect within ~10-30 min: rows in `Clip_Queue`, then `Ready_Clips` with `ready_to_post`, Discord message, MP4 in `./output`.
Render only one clip: `POST /webhook/process-clip` with `{"vod_id":"…","start_time":3600,"end_time":3665,"streamer":"…"}`.
Force a post: open workflow 04 → **Execute workflow**.

---

## 8. Daily use

The machine runs alone. Your job each day (~20 min):

1. Look at `Ready_Clips` — set bad ones to `skipped` before the next slot.
2. Reply to comments in the first hour after each post (11/15/19/22 h New York = 17/21/01/04 h Paris).
3. Sunday: weekly review (see 30-day plan).

Monitoring: `http://<droplet-ip>:3001` (Uptime Kuma) → add a monitor on `https://<DOMAIN>/healthz`.

---

## 9. Update the server after changing code

```bash
cd /opt/tiktok-clips/TikTokBPlan
git pull
docker compose build n8n
docker compose up -d --remove-orphans      # --remove-orphans drops the old redis/whisper containers
```
Re-import a workflow in n8n only if its JSON changed (n8n does not read `workflows/` automatically).

Cleanup old files weekly: `docker exec tiktok-clips-n8n find /temp /output -mtime +3 -type f -delete`.

---

## 10. When something breaks

First run: `bash /opt/tiktok-clips/TikTokBPlan/diagnose.sh` — it checks containers, tools, model, HTTPS, legal pages, Caddyfile, disk and prints last logs. Changes nothing.

| Symptom | Fix |
|---------|-----|
| Blank n8n page / "MIME type ''" | Caddyfile must use bare `handle {` as catch-all (not `handle / {`). Re-run `deploy-droplet.sh`, then `docker compose restart caddy` |
| No HTTPS | DNS not pointing to droplet yet, or `CADDY_EMAIL` empty. `docker logs tiktok-clips-caddy` |
| `unaudited_client_can_only_post_to_private_accounts` | App not audited: account must be private + `TIKTOK_PRIVACY_LEVEL=SELF_ONLY` |
| TikTok 401 | Access token expired (24 h). Refresh with the refresh token, update `.env`, recreate n8n |
| Analyzer "Failed to download VOD" | VOD deleted/sub-only, or yt-dlp outdated → `docker compose build --no-cache n8n` |
| Google Sheets 403 | Sheet not shared with the service account email |
| No post at a slot | No `ready_to_post` row left — normal, 04 stops quietly |
| Disk full | Clean `/temp` and `/output` (command in §9) |

---

## 11. Legal — read once, really

Reposting someone else's stream without permission risks DMCA strikes, bans, and **TikTok refuses "unoriginal" content for Creator Rewards**. Use one of:

1. **Written permission** from each streamer (best — also opens paid clipping deals, see plan).
2. Clips the streamer published themselves (clips.twitch.tv).
3. **Transformative** edits: voiceover, commentary, context.

No copyrighted music in clips (game audio is fine).

---
*Last cleanup: 2026-11-24.*
