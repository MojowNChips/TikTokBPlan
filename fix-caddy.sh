#!/bin/bash
# Fix Caddy empty-body issue for n8n static assets
# Run on the droplet terminal

set -e

cd /opt/tiktok-clips/TikTokBPlan

echo "=== Step 1: Check current state ==="
docker ps --format 'table {{.Names}}	{{.Status}}	{{.Ports}}'
echo ""

echo "=== Step 2: Backup and rewrite Caddyfile ==="
cp Caddyfile Caddyfile.bak.$(date +%s)

cat > Caddyfile << 'CFEOF'
{
    email ${CADDY_EMAIL}
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

    # n8n — catch-all LAST with proper transport settings
    handle / {
        reverse_proxy n8n:5678 {
            header_up Host {upstream_hostport}
            header_up X-Real-IP {remote_host}
            header_up X-Forwarded-For {remote_host}
            header_up X-Forwarded-Proto {scheme}
            header_up X-Forwarded-Port {server_port}
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

echo "New Caddyfile:"
cat Caddyfile
echo ""

echo "=== Step 3: Restart Caddy ==="
export DOMAIN=claudinesclip.online
export CADDY_EMAIL=mounier.romaric1@gmail.com

docker compose up -d caddy

sleep 5

echo "=== Step 4: Test assets ==="
echo "Direct n8n:"
curl -s -o /dev/null -w "  %{http_code}, Size: %{size_download}\n" http://localhost:5678/assets/index--J3eexb7.js

echo "Through Caddy:"
curl -sk -o /dev/null -w "  %{http_code}, Type: %{content_type}, Size: %{size_download}\n" https://claudinesclip.online/assets/index--J3eexb7.js

echo ""
echo "=== Step 5: Test main page ==="
curl -sk -o /dev/null -w "Caddy HTML: %{http_code}, Type: %{content_type}, Size: %{size_download}\n" https://claudinesclip.online/

echo ""
echo "=== Done ==="
echo "If Caddy asset now shows a real size (not 0), open https://claudinesclip.online in incognito."
