# Google Sheets Setup for TikTok Clips Automation

Create a new Google Sheet and share it with your service account email. Then create these tabs:

## Tab 1: VOD_Queue
**Columns (A-J):**
| A | B | C | D | E | F | G | H | I | J |
|---|---|---|---|---|---|---|---|---|---|
| vod_id | streamer | title | game | duration | url | thumbnail | created_at | view_count | status |

**Example row:**
```
123456789 | shroud | "INSANE CLUTCH 1v5" | Valorant | 7200 | https://twitch.tv/videos/123456789 | https://thumb.url | 2024-01-15T20:00:00Z | 50000 | queued
```

---

## Tab 2: Clip_Queue
**Columns (A-L):**
| A | B | C | D | E | F | G | H | I | J | K | L |
|---|---|---|---|---|---|---|---|---|---|---|---|
| clip_id | vod_id | streamer | game | start_time | end_time | title | reason | score | status | review_url | created_at |

**Example row:**
```
clip_123456789_3600 | 123456789 | shroud | Valorant | 3600 | 3645 | "1v5 Clutch" | "chat explosion, audio spike" | 87 | pending_review | https://discord.com/... | 2024-01-15T21:00:00Z
```

---

## Tab 3: Ready_Clips
**Columns (A-N):**
| A | B | C | D | E | F | G | H | I | J | K | L | M | N |
|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
| clip_id | vod_id | streamer | game | start_time | end_time | title | reason | score | video_path | video_url | file_size_mb | status | posted_at |

**Status values:** `ready_to_post`, `posted`, `failed`, `skipped`

---

## Tab 4: Analytics
**Columns (A-H):**
| A | B | C | D | E | F | G | H |
|---|---|---|---|---|---|---|---|
| posted_at | clip_id | streamer | game | pillar | publish_id | status | views |
| | | | | | | | likes |
| | | | | | | | comments |
| | | | | | | | shares |
| | | | | | | | saves |

**Extended columns (I-P):**
| I | J | K | L | M | N | O | P |
|---|---|---|---|---|---|---|---|
| likes | comments | shares | saves | updated_at | retention_3s | retention_10s | retention_30s |

---

## Tab 5: Streamer_Performance
**Columns (A-G):**
| A | B | C | D | E | F | G |
|---|---|---|---|---|---|---|
| streamer | total_clips | total_views | avg_views | best_clip_id | best_clip_views | last_updated |

---

## Tab 6: Game_Performance
**Columns (A-F):**
| A | B | C | D | E | F |
|---|---|---|---|---|---|
| game | total_clips | total_views | avg_views | top_pillar | last_updated |

---

## Tab 7: Pillar_Performance
**Columns (A-F):**
| A | B | C | D | E | F |
|---|---|---|---|---|---|
| pillar | total_clips | total_views | avg_views | avg_engagement_rate | last_updated |

---

## Setup Instructions

1. **Create Google Cloud Project:**
   - Go to https://console.cloud.google.com/
   - Create new project: "TikTok Clips Automation"
   - Enable Google Sheets API and Google Drive API

2. **Create Service Account:**
   - IAM & Admin → Service Accounts → Create Service Account
   - Name: "tiktok-clips-bot"
   - Grant: Editor (or custom role with Sheets/Drive access)
   - Create key → JSON → Save as `credentials.json`

3. **Share Sheet:**
   - Open your Google Sheet
   - Share with service account email (from JSON: `client_email`)
   - Give Editor access

4. **Add to .env:**
   ```bash
   GOOGLE_SHEETS_CREDENTIALS_JSON={"type":"service_account","project_id":"...","private_key_id":"...","private_key":"-----BEGIN PRIVATE KEY-----\n...\n-----END PRIVATE KEY-----\n","client_email":"tiktok-clips-bot@your-project.iam.gserviceaccount.com","client_id":"...","auth_uri":"https://accounts.google.com/o/oauth2/auth","token_uri":"https://oauth2.googleapis.com/token","auth_provider_x509_cert_url":"https://www.googleapis.com/oauth2/v1/certs","client_x509_cert_url":"https://www.googleapis.com/robot/v1/metadata/x509/tiktok-clips-bot%40your-project.iam.gserviceaccount.com"}
   GOOGLE_SHEET_ID=1abc123def456ghi789jkl (from sheet URL: https://docs.google.com/spreadsheets/d/THIS_PART/edit)
   ```

5. **Test in n8n:**
   - Add Google Sheets credential in n8n
   - Test each workflow node

---

## Formulas for Dashboard (Optional)

Add a "Dashboard" tab with these formulas:

```excel
// Total followers gained (manual entry)
=B1  // Enter manually daily

// Clips posted this week
=COUNTIF(Ready_Clips!M:M, "posted") - COUNTIF(Ready_Clips!M:M, "posted", Ready_Clips!N:N, "<"&TODAY()-7)

// Average views per clip
=AVERAGEIF(Analytics!G:G, ">0", Analytics!H:H)

// Top performing streamer
=INDEX(Streamer_Performance!A:A, MATCH(MAX(Streamer_Performance!D:D), Streamer_Performance!D:D, 0))

// Best pillar
=INDEX(Pillar_Performance!A:A, MATCH(MAX(Pillar_Performance!D:D), Pillar_Performance!D:D, 0))

// Viral clips (>100k views)
=COUNTIF(Analytics!H:H, ">100000")
```

---

## Service Account Permissions Needed

```json
{
  "role": "projects/your-project/roles/tiktokClipsEditor",
  "includedPermissions": [
    "sheets.spreadsheets.get",
    "sheets.spreadsheets.values.get",
    "sheets.spreadsheets.values.update",
    "sheets.spreadsheets.values.append",
    "drive.files.get",
    "drive.files.list"
  ]
}
```