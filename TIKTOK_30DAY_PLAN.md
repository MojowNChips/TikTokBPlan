# TikTok Streamer Clips - 30 Day Automation Plan

## Goal
Reach TikTok Creator Rewards (10k followers, 100k views in 30 days) using automated clip pipeline from public Twitch/Kick VODs.

---

## ⚠️ CRITICAL LEGAL WARNING
**Using public VODs without explicit permission risks:**
- TikTok demonetization (not "original content")
- Copyright strikes (DMCA takedowns)
- Account bans

**Safer alternatives (choose one):**
1. **Partner with streamers** - Get written permission + VOD access
2. **Use clips.twitch.tv only** - Streamers' own curated clips
3. **Add transformative commentary** - Voiceover, analysis, editing (fair use stronger)
4. **Creative Commons / royalty-free gaming content**

This system builds the automation. YOU decide the legal path.

---

## Phase 1: Foundation (Days 1-7)
**Target: 1,000 followers, 10k views**

### Content Strategy
- **3 content pillars** (pick 3, rotate daily):
  1. **Insane Plays** - High-skill moments, clutches, outplays
  2. **Funny/Fail Moments** - Rage, bugs, unexpected humor
  3. **Streamer Reactions** - Genuine reactions to games/news

### Technical Setup
- [ ] n8n self-hosted (Docker on VPS or local)
- [ ] Twitch API app registered (Client ID/Secret)
- [ ] Kick API access (if available)
- [ ] TikTok Developer account + API access
- [ ] FFmpeg installed for video processing
- [ ] Whisper.cpp for auto-captions (local, free)

### Clip Selection Criteria (Automated)
```
MUST HAVE:
- Duration: 15-59 seconds (TikTok sweet spot)
- Vertical 9:16 or easily cropable
- Clear audio (game + mic)
- Visually engaging (action on screen)

SCORING (0-100):
- Peak concurrent viewers during moment (0-30)
- Chat velocity (messages/sec) (0-25)
- Visual change detection (motion score) (0-20)
- Audio energy (volume spikes) (0-15)
- Keywords in chat/title (clutch, insane, lol, wtf) (0-10)

THRESHOLD: Score > 65 = auto-queue for review
```

### Daily Output
- **3-5 clips/day** (test what works)
- Post times: 11am, 3pm, 7pm, 10pm EST (4 slots)
- Hashtag sets per pillar (pre-defined)

---

## Phase 2: Optimization (Days 8-14)
**Target: 3,000 followers, 50k views**

### A/B Testing Framework
- Test 2 variants per clip:
  - Hook: First 3 seconds (text overlay vs voice vs action)
  - Caption style: Question vs statement vs CTA
  - Hashtag count: 3 vs 5 vs 8
  - Post time slots

### Analytics Tracking (n8n → Google Sheets)
- Views, likes, shares, comments, saves, follows
- Retention graph (0-3s, 3-10s, 10-30s, 30+)
- Traffic source (FYP, following, search, profile)
- Clip metadata (streamer, game, pillar, score)

### Double Down
- Identify top 2 performing pillars
- Increase output to 5-7 clips/day
- Focus on top-performing streamers/games
- Build "series" (e.g., "Daily [Game] Clutches")

---

## Phase 3: Scale (Days 15-21)
**Target: 6,000 followers, 100k views**

### Content Expansion
- Add 4th pillar: **Educational/Tips** (high save rate)
- Start "Best of Week" compilations (Saturday)
- Cross-post to YouTube Shorts / Reels (same n8n flow)
- Engage with comments (auto-reply templates + manual)

### Automation Enhancements
- Smart scheduling: post when followers most active
- Auto-retry failed uploads
- Duplicate detection (don't re-post same moment)
- Streamer notification: "Your clip posted!" (Discord/webhook)

### Community Building
- Pin comment asking for clip suggestions
- Reply to every comment first 2 hours
- Feature fan-submitted timestamps
- Shoutout streamers in captions

---

## Phase 4: Monetization Ready (Days 22-30)
**Target: 10,000+ followers, 100k+ views (qualify for Creator Rewards)**

### Final Push
- 7-10 clips/day (max sustainable)
- 1-2 "viral attempt" clips (trending sounds, formats)
- Collab with other clip pages (shoutout swaps)
- Run 1 giveaway (follow + share = entry)

### System Hardening
- Error alerting (Discord/email on failures)
- Backup VPS / local failover
- Documentation for handoff
- Cost optimization review

### Legal Compliance Check
- [ ] Every clip has streamer permission OR transformative commentary
- [ ] TikTok "Original Content" guidelines met
- [ ] Music copyright cleared (game audio OK, background music risky)
- [ ] Brand safety: no controversial streamers

---

## Clip Pipeline Architecture

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│  FETCH      │────▶│  ANALYZE    │────▶│  CLIP       │────▶│  POST       │
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

## n8n Workflows Needed

| Workflow | Trigger | Key Nodes |
|----------|---------|-----------|
| **Daily VOD Fetch** | Cron (2am) | Twitch API → Filter → Queue |
| **Clip Analyzer** | Queue webhook | Whisper → Score → Filter → Approve |
| **Video Processor** | Approve webhook | FFmpeg → Caption → Watermark → Upload to storage |
| **TikTok Publisher** | Cron (4x/day) | Get next clip → TikTok API → Log analytics |
| **Analytics Collector** | Cron (hourly) | TikTok API → Google Sheets → Alert if viral |
| **Streamer Notifier** | Post success | Discord webhook → Message streamer |

---

## Free/Open Source Stack

| Component | Tool | Cost |
|-----------|------|------|
| Automation | n8n (self-hosted) | $0 (VPS ~$5/mo) |
| Video Processing | FFmpeg | $0 |
| Transcription | Whisper.cpp (local) | $0 (CPU) / $0.01/min (API) |
| Clip Scoring | Custom Python/Node | $0 |
| Storage | Local / Cloudflare R2 | $0-5/mo |
| Analytics | Google Sheets API | $0 |
| Scheduling | n8n cron | $0 |
| Monitoring | Uptime Kuma | $0 |

**Estimated monthly: $5-15** (VPS + minimal storage)

---

## 30-Day Checklist

### Week 1
- [ ] n8n deployed and accessible
- [ ] Twitch/Kick API credentials working
- [ ] TikTok Developer app approved
- [ ] FFmpeg + Whisper.cpp installed
- [ ] First 3 workflows built and tested
- [ ] 15 clips posted, analytics baseline

### Week 2
- [ ] A/B testing framework live
- [ ] Analytics dashboard (Google Sheets)
- [ ] Top 2 pillars identified
- [ ] 50+ clips posted
- [ ] 1,000+ followers

### Week 3
- [ ] Cross-posting to Shorts/Reels
- [ ] Streamer notification system
- [ ] Smart scheduling active
- [ ] 100+ clips posted
- [ ] 5,000+ followers

### Week 4
- [ ] Error alerting + monitoring
- [ ] Legal compliance audit
- [ ] Documentation complete
- [ ] 10,000+ followers
- [ ] Creator Rewards application ready

---

## Risk Mitigation

| Risk | Probability | Impact | Mitigation |
|------|-------------|--------|------------|
| TikTok API rate limits | High | Medium | Queue + retry logic, multiple apps |
| Copyright strikes | Medium | High | Permission system, transformative edits |
| Low clip quality | High | Medium | Scoring threshold, human review gate |
| VPS downtime | Low | High | Backup VPS, local n8n ready |
| Algorithm changes | Medium | High | Diversify platforms, build email list |
| Burnout | High | Medium | Automate everything, batch work |

---

## Success Metrics (Daily Tracking)

| Metric | Week 1 | Week 2 | Week 3 | Week 4 |
|--------|--------|--------|--------|--------|
| Followers | 250/day | 300/day | 400/day | 500/day |
| Views/clip | 500 | 1,000 | 2,000 | 3,000+ |
| Clips/day | 3 | 5 | 7 | 8 |
| Follow rate | 2% | 3% | 4% | 5% |
| Save rate | 1% | 2% | 3% | 4% |

---

## Next Steps

1. **Confirm legal approach** - How will you source clips legally?
2. **Pick VPS provider** - DigitalOcean, Hetzner, Linode (~$5-6/mo)
3. **Register Twitch Dev App** - https://dev.twitch.tv/console
4. **Apply for TikTok Developer** - https://developers.tiktok.com/
5. **Choose 3 starting games/streamers** - Focus the fetcher
6. **Deploy n8n** - I'll provide Docker compose + workflows

---

*Generated: 2026-11-18 | Update weekly based on analytics*