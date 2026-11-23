#!/bin/bash
# Fix Caddy MIME type issue for n8n asset files
# Run on the droplet: bash fix-caddy-mime.sh
#
# IMPORTANT: Ensure DOMAIN and CADDY_EMAIL env vars are set before running!

set -e

cd /opt/tiktok-clips/TikTokBPlan

echo "=== Current Caddyfile check ==="
grep "header_down" Caddyfile && echo "PROBLEM FOUND: header_down * exists" || echo "No header_down found"

echo ""
echo "=== Backbling Caddyfile ==="
cp Caddyfile "Caddyfile.bak.$(date +%s)"
echo "Backed up to Caddyfile.bak.$(date +%s)"

echo ""
echo "=== Fixing Caddyfile ==="

# Create the fixed Caddyfile with:
# 1. Fully rendered domain (no template variables)
# 2. Explicit Content-Type header preservation
# 3. Transport http with buffers
cat > Caddyfile << 'CFEOF'
{
    email admin@claudinesclip.online
    encode gzip
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
            # EXPLICITLY preserve Content-Type from upstream - REQUIRED for JS modules
            header_up Content-Type {upstream_content_type}
            transport http {
                read_buffer 4MB
                write_buffer 4MB
            }
        }
    }

    # Health check
    handle /healthz {
        reverse_proxy n8n:5678
    }

    # Favicon fallback
    handle_path /favicon.ico {
        reverse_proxy docs:80
    }
}
CFEOF

echo "Fixed Caddyfile created"

echo ""
echo "=== Force restarting Caddy (stop + rm -f + up) ==="
docker compose stop caddy
sleep 2
docker compose rm -f caddy
docker compose up -d caddy

echo ""
echo "=== Waiting for Caddy to start ==="
sleep 8

echo ""
echo "=== Verification ==="
echo "Direct n8n (port 5678):"
curl -s -o /dev/null -w "  Status: %{http_code}, Size: %{size_download} bytes\n" http://localhost:5678/assets/index--J3eexb7.js 2>&1 || echo "  n8n not responding on port 5678"

echo ""
echo "Through Caddy (HTTPS):"
curl -sk -I https://claudinesclip.online/assets/index--J3eexb7.js 2>&1 | head -20

echo ""
echo "=== Main page test ==="
curl -sk -o /dev/null -w "  Status: %{http_code}, Type: %{content_type}\n" https://claudinesclip.online/ 2>&1

echo ""
echo "=== If Content-Type shows application/javascript, the fix is complete ==="
echo "Open https://claudinesclip.online in an incognito window"