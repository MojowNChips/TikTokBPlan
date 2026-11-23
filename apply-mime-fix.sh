#!/bin/bash
# ==============================================================================
# Fix MIME Type Errors in Chrome DevTools
# Resolves "Expected a JavaScript-or-Wasm module script but server responded 
# with a MIME type of empty string"
# ==============================================================================

set -euo pipefail

# Configuration - adjust if needed
DOMAIN="${DOMAIN:-claudinesclip.online}"
CADDY_EMAIL="${CADDY_EMAIL:-admin@${DOMAIN}}"

echo "================================================================"
echo "  MIMETYPE FIX - Applying to $DOMAIN"
echo "================================================================"
echo ""

cd /opt/tiktok-clips/TikTokBPlan

# Step 0: Check current state
echo "[0/5] Checking current state..."
if [ -f Caddyfile ]; then
    if grep -q "header_down" Caddyfile; then
        echo "  WARNING: header_down directive found in Caddyfile"
    else
        echo "  No header_down directive found (good)"
    fi
else
    echo "  ERROR: Caddyfile not found!"
    exit 1
fi

# Step 1: Show current Caddyfile (first 15 lines)
echo ""
echo "[1/5] Current Caddyfile header:"
head -15 Caddyfile

# Step 2: Create backup
echo ""
echo "[2/5] Backing up current Caddyfile..."
cp Caddyfile "Caddyfile.bak.$(date +%Y%m%d_%H%M%S)"
echo "  Backup created: Caddyfile.bak.$(date +%Y%m%d_%H%M%S)"

# Step 3: Create fixed Caddyfile with:
# - Fully rendered domain (no template variables)
# - Explicit Content-Type header preservation
# - Transport http with buffers
echo ""
echo "[3/5] Creating fixed Caddyfile..."
cat > Caddyfile << 'CFEOF'
{
    email admin@claudinesclip.online
}

claudinesclip.online {

    # TikTok legal docs — specific routes FIRST
    handle_path /privacy {
        reverse_proxy docs:80
    }

    handle_path /terms {
        reverse_proxy docs:80
    }

    handle_path /data-usage {
        reverse_proxy docs:80
    }

    handle_path /app-description {
        reverse_proxy docs:80
    }

    handle_path /logo.png {
        reverse_proxy docs:80
    }

    # n8n — catch-all LAST with explicit header preservation
    handle / {
        reverse_proxy n8n:5678 {
            header_up Host {upstream_hostport}
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
            header_up X-Forwarded-Port {server_port}
            # EXPLICITLY preserve Content-Type from upstream - REQUIRED for JS modules
            header_up Content-Type {upstream_content_type}
            transport http {
                read_buffer 4MB
                write_buffer 4MB
            }
        }
    }

    handle /healthz {
        reverse_proxy n8n:5678
    }

    # Favicon fallback
    handle_path /favicon.ico {
        reverse_proxy docs:80
    }
}
CFEOF

# Step 4: Force restart Caddy with fresh container
echo ""
echo "[4/5] Force restarting Caddy..."
docker compose stop caddy
sleep 2
docker compose rm -f caddy
docker compose up -d caddy

# Step 5: Verify
echo ""
echo "[5/5] Verification..."
sleep 8

echo ""
echo "=== JS Asset Test ==="
curl -sk -I https://claudinesclip.online/assets/index--J3eexb7.js 2>&1 | head -20

echo ""
echo "=== Main Page Test ==="
curl -sk -o /dev/null -w "Status: %{http_code}, Type: %{content_type}\n" https://claudinesclip.online/ 2>&1

echo ""
echo "================================================================"
echo "  DONE - If Content-Type shows application/javascript, fix is complete!"
echo "  Open https://claudinesclip.online in incognito to verify"
echo "================================================================"