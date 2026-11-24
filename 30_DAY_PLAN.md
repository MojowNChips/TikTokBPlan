# 30-Day Plan — TikTok Streamer Clips

*Clean version of TIKTOK_30DAY_PLAN.md, reviewed against TikTok's current rules (Nov 2026).*

---

## 0. Reality check — 4 things the old plan missed

| # | Problem | Why it matters | What we do |
|---|---------|----------------|------------|
| 1 | **Creator Rewards pays only on videos longer than 1 minute** (plus 18+, 10k followers, 100k views in 30 days, original content, ≥1,000 For You views per video). | The pipeline cuts **30 s** clips → even at 10k followers, those earn **€0**. | Short clips (30 s) for growth in weeks 1-2, then `CLIP_WINDOW=65`+ for every clip you want paid. |
| 2 | **Unaudited TikTok apps post privately only** (SELF_ONLY, max 5 users/day, account must be private). | Until the audit passes, the API can't grow a public account. | Submit the audit on day 0. Meanwhile post the rendered MP4s **by hand** from the TikTok app (download from `./output` or R2). |
| 3 | **"Original content" rule.** Raw re-uploads of someone's stream are flagged unoriginal. | Unoriginal = no Creator Rewards, weaker reach, strike risk. | Every clip gets real added value: hook text, context caption, ideally a 2-3 s voice intro. Streamer permission first. |
| 4 | Creator Rewards pays roughly **$0.40-1.00 per 1,000 qualified views**. | 100k views ≈ $40-100. Not a business on its own. | Add a second, faster revenue line: **paid clipping for streamers** (see §6). |

**Targets are a stretch.** 10k followers in 30 days from zero is possible for a clip page but not typical. Plan uses a **base** and a **stretch** target; decisions are made on the weekly gates, not on hope.

---

## 1. Day 0 — before posting anything (do it in 1-2 days)

- [ ] Pick the legal path: **written OK from 3 streamers** (DM template in §7) → fallback clips.twitch.tv.
- [ ] Pick **1 game + 3 streamers** (mid-size: 1k-20k live viewers — big ones are over-clipped, small ones have no audience).
- [ ] TikTok account: niche name (`<game>clipsdaily`-style), avatar, bio with promise ("Best <game> clutches every day").
- [ ] Submit the TikTok app audit (REVIEW_PACK.pdf). Set `TIKTOK_PRIVACY_LEVEL=SELF_ONLY`.
- [ ] Deploy + test one VOD end-to-end (GUIDE §4-7).
- [ ] Set `CLIP_WINDOW=30`, `CLIP_SCORE_THRESHOLD=60`, `MAX_CLIPS_PER_VOD=3`.

---

## 2. The 4 phases

| Phase | Days | Base target | Stretch | Clips/day | Length | Focus |
|-------|------|-------------|---------|-----------|--------|-------|
| 1 Foundation | 1-7 | 300 followers, 10k views | 1k / 30k | 3 | 30 s | Find what hooks; manual posting while audit pending |
| 2 Optimize | 8-14 | 1.5k, 50k | 3k / 100k | 4 | 30 s + 1 test 65 s/day | Double down on top pillar + streamer |
| 3 Scale | 15-21 | 4k, 120k | 6k / 250k | 4-5 | 50/50 30 s and 65 s | Series, cross-post Shorts/Reels |
| 4 Monetize | 22-30 | 8k, 200k | 10k+ / 400k | 4-5 | Mostly 65-90 s | Qualify, apply, lock paid clipping deals |

Volume stays at 3-5/day. More than that from a young account looks like spam and dilutes watch time — **quality beats count**.

---

## 3. Week by week

### Week 1 — Foundation (days 1-7)
- 3 pillars, rotate: **Insane plays** · **Funny / fails** · **Reactions**.
- Every clip: hook text in the first second ("He had 1 HP…"), captions on, 3-5 hashtags (niche + game, not just #fyp).
- Reply to every comment within 1 h of posting.
- Daily: check `Ready_Clips`, skip weak clips.
- **Gate day 7:** at least 1 clip > 2k views? Yes → continue. No → change streamer or game, not the volume.

### Week 2 — Optimize (days 8-14)
- One change at a time (A/B): hook style, caption question vs statement, post slot.
- Compare in `Analytics`: **watch-through and shares**, not likes.
- Kill the weakest pillar, add a "series" name for the best one ("Daily <game> Clutch #12") — series bring follows.
- Start 1 × 65 s clip/day to learn what holds people past 1 min (setup → play → reaction).
- If audit approved → `TIKTOK_PRIVACY_LEVEL=PUBLIC_TO_EVERYONE`, let workflow 04 post.
- **Gate day 14:** follows per 1k views ≥ 3? Yes → scale. No → the clips get views but not follows: fix bio + add series.

### Week 3 — Scale (days 15-21)
- Half the clips at 65 s (`CLIP_WINDOW=65`).
- Saturday: "Best of the week" compilation (2-3 min — compilations easily pass the 1-min rule).
- Cross-post the same MP4s to YouTube Shorts + Instagram Reels (Shorts accepts up to 3 min).
- Tag the streamer in captions; send them their best clip (they often repost → free reach).
- **Gate day 21:** on track for 100k views in a rolling 30 days? If not, focus the last 9 days on the single best streamer.

### Week 4 — Monetize (days 22-30)
- Mostly 65-90 s clips + 2 compilations.
- 1-2 trend attempts per week (trending format, not trending copyrighted music).
- Collab/shoutout swap with 1-2 clip pages of similar size.
- When 10k / 100k reached → apply in TikTok Studio → Creator Rewards.
- Close at least 1 paid clipping deal (§6).

---

## 4. Daily routine (≈ 20 min)

| When (Paris) | What |
|--------------|------|
| Morning | Check `Ready_Clips`, mark weak ones `skipped`; check Discord for errors |
| 17h · 21h · 01h · 04h | Posts go out (11/15/19/22 h New York). If awake, reply to comments in the first hour |
| Evening | 5 min in TikTok Studio: retention graph of yesterday's best clip |

Tip: the 01 h / 04 h Paris slots are useless for replying. If the audience ends up European, change the cron in workflow 04 and `GENERIC_TIMEZONE`.

---

## 5. Weekly review (Sunday, 30 min)

1. Top 3 and bottom 3 clips: what was different in the first 2 seconds?
2. Best streamer / game / pillar → more of that next week.
3. Follows per 1k views, average watch time, shares.
4. Tune `CLIP_SCORE_THRESHOLD` (too many weak clips → raise to 65-70).
5. Server: run `diagnose.sh`, disk space.

### KPIs that actually matter

| Metric | Week 1 | Week 2 | Week 3 | Week 4 |
|--------|--------|--------|--------|--------|
| Avg views / clip | 500 | 1,000 | 2,000 | 3,000+ |
| Follows / 1k views | 2 | 3 | 4 | 5 |
| Avg watch time (65 s clips) | — | 20 s | 30 s | 35 s+ |
| Share rate | 0.5% | 1% | 1.5% | 2% |

---

## 6. Money — don't wait for 10k

| Source | When | Rough value |
|--------|------|-------------|
| **Paid clipping for streamers** — they pay you per clip or per 1k views to grow their TikTok | From week 1 (with 2-3 good clips as portfolio) | Often more than Creator Rewards at this size |
| Clipping campaigns / platforms paying per 1k views | Week 2+ | Per campaign rules |
| Creator Rewards | After 10k + 100k, on > 1 min videos | ~$0.40-1.00 / 1k qualified views |
| Shorts / Reels | Same clips, more reach | Bonus |

The permission DM below doubles as a sales pitch.

---

## 7. Streamer DM template

> Hey <name>! I run a clip page for <game>. I'd love to cut your best moments into TikToks — captions, your @ on every clip, link to your Twitch. Free at first, I'll send you the stats. OK if I post clips from your VODs? A simple "yes" here is enough as written permission 🙏

Save every "yes" (screenshot) in a `permissions/` folder.

---

## 8. Risks

| Risk | Odds | Fix |
|------|------|-----|
| Audit slow / refused | Medium | Manual posting; re-submit using REVIEW_PACK checklist |
| Copyright strike | Medium | Permission only; remove clip immediately; no copyrighted music |
| Clips get views, no follows | High | Series naming, bio promise, end each clip on a cliff-hanger |
| Token expired (TikTok access token lasts 24 h) | High | Refresh daily — **next improvement: auto-refresh node in workflow 04** |
| Droplet down | Low | Uptime Kuma alert, `docker compose up -d` |

---

## 9. Ideas for later

- **Auto token refresh** (TikTok + Twitch) — removes the #1 daily failure.
- **Approval button in Discord**: clip arrives → ✅ / ❌ → only approved clips get `ready_to_post`.
- **AI hook text** per clip from the transcript (first-second overlay).
- **Inbox upload mode** of the TikTok API (draft sent to your app, you publish) as an alternative while not audited — check TikTok's current rules first.
- Twitch chat velocity in the score (chat spikes = best moments) — already planned in the old doc, not implemented yet.
