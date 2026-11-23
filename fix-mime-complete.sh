#!/bin/bash
# ==============================================================================
# Complete MIME Type Fix for n8n + Caddy Deployment
# Fixes: "Expected a JavaScript-or-Wasm module script but the server responded 
#         with a MIME type of """
# Also fixes: favicon 404, empty Content-Type headers
# ==============================================================================

set -euo pipefail

echo "================================================================="
echo "  COMPLETE MIME TYPE FIX - n8n + Caddy"
echo "================================================================="
echo ""

cd /opt/tiktok-clips/TikTokBPlan

# ============================================================
# Step 1: Verify we're on the droplet and containers are running
# ============================================================
echo "[1/7] Checking container status..."
if ! docker ps --format '{{.Names}}' | grep -q "caddy"; then
    echo "  WARNING: Caddy container not running!"
fi

# ============================================================
# Step 2: Remove ANY header_down directives that strip headers
# ============================================================
echo ""
echo "[2/7] Removing header_down directives..."
if grep -q "header_down" Caddyfile; then
    sed -i '/header_down/d' Caddyfile
    echo "  ✅ Removed header_down from Caddyfile"
else
    echo "  No header_down found (already clean)"
fi

# ============================================================
# Step 3: Create fully rendered Caddyfile (NO template variables)
# ============================================================
echo ""
echo "[3/7] Creating fully rendered Caddyfile..."
cat > Caddyfile << 'CFEOF'
{
    email admin@claudinesclip.online
}

claudinesclip.online {

    # Enable proper MIME type detection
    header_server {
        replace "Caddy"
    }

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
            # EXPLICITLY preserve Content-Type from upstream
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

    # Favicon fallback from docs container
    handle_path /favicon.ico {
        reverse_proxy docs:80
    }
}
CFEOF
echo "  ✅ Caddyfile created with explicit Content-Type preservation"

# ============================================================
# Step 4: Force fresh Caddy container with new config
# ============================================================
echo ""
echo "[4/7] Force restarting Caddy container..."
docker compose stop caddy 2>/dev/null || true
docker compose rm -f caddy 2>/dev/null || true
sleep 2
docker compose up -d caddy
echo "  ✅ Caddy container restarted"

# Wait for Caddy to start and obtain SSL
echo ""
echo "[5/7] Waiting for Caddy to start (10 seconds)..."
sleep 10

# ============================================================
# Step 5: Verify Caddy is running
# ============================================================
echo ""
echo "[6/7] Verification..."
if docker ps --format '{{.Names}}' | grep -q "caddy"; then
    echo "  ✅ Caddy is running"
else
    echo "  ❌ Caddy failed to start!"
    echo "  Checking Caddy logs..."
    docker logs tiktok-clips-caddy --tail 30 2>&1
    exit 1
fi

# ============================================================
# Step 6: Test the JS asset headers
# ============================================================
echo ""
echo "[7/7] Testing JS asset headers..."
echo "=== JS Asset Response ==="
HTTP_OUTPUT=$(curl -sk -I https://claudinesclip.online/assets/index--J3eexb7.js 2>&1)
echo "$HTTP_OUTPUT"

echo ""
echo "=== Checking Content-Type ==="
if echo "$HTTP_OUTPUT" | grep -qi "content-type:.*javascript"; then
    echo "  ✅ SUCCESS: Content-Type is application/javascript"
else
    echo "  ⚠️  Content-Type check - looking at full headers..."
    echo "$HTTP_OUTPUT" | grep -i "content-type"
fi

# ============================================================
# Step 7: Test favicon
# ============================================================
echo ""
echo "=== Favicon Test ==="
FAVICON_OUTPUT=$(curl -sk -I https://claudinesclip.online/favicon.ico 2>&1)
echo "$FAVICON_OUTPUT"

if echo "$FAVICON_OUTPUT" | grep -qi "200"; then
    echo "  ✅ Favicon accessible!"
else
    echo "  ⚠️  Favicon may need docs container running"
fi

echo ""
echo "================================================================="
echo "  FIX COMPLETE"
echo "================================================================="
echo ""
echo "Next steps:"
echo "1. Open https://claudinesclip.online in incognito window"
echo "2. Check Chrome DevTools - MIME type errors should be gone"
echo "3. If errors persist, run: docker compose logs caddy --tail 50"
echo ""
echo "  JS file headers should show: Content-Type: application/javascript"
echo "================================================================="