#!/bin/bash
# ==============================================================================
# Full diagnostic for MIME type issues
# Run on droplet: bash diagnose-full.sh
# ==============================================================================

set -euo pipefail

echo "Running from: $(pwd)"
echo "Script location: $(dirname "$0")"
cd "$(dirname "$0")"

if [ ! -f docker-compose.yml ]; then
    cd /opt/tiktok-clips/TikTokBPlan
fi

echo "Working directory: $(pwd)"

echo "================================================================"
echo "  FULL DIAGNOSTIC - MIME TYPE ISSUES"
echo "================================================================"

# 1. Check container status
echo ""
echo "[1] Container Status:"
echo "----------------------------------------"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

# 2. Check Caddyfile content (first 25 lines)
echo ""
echo "[2] Caddyfile content (first 25 lines):"
echo "----------------------------------------"
head -25 Caddyfile

# 3. Check if header_down exists anywhere
echo ""
echo "[3] Checking for header_down:"
echo "----------------------------------------"
if grep -q "header_down" Caddyfile; then
    echo "PROBLEM: header_down found!"
    grep "header_down" Caddyfile
else
    echo "No header_down found (good)"
fi

# 4. Test direct to n8n
echo ""
echo "[4] Direct n8n test (port 5678):"
echo "----------------------------------------"
echo "Response headers:"
curl -s -I http://localhost:5678/assets/index--J3eexb7.js 2>&1 | head -20
echo ""
echo "Response size:"
curl -s -o /dev/null -w "Size: %{size_download} bytes\n" http://localhost:5678/assets/index--J3eexb7.js 2>&1

# 5. Test through Caddy
echo ""
echo "[5] Through Caddy (HTTPS):"
echo "----------------------------------------"
echo "Response headers:"
curl -sk -I https://claudinesclip.online/assets/index--J3eexb7.js 2>&1 | head -20
echo ""
echo "Response size:"
curl -sk -o /dev/null -w "Size: %{size_download} bytes\n" https://claudinesclip.online/assets/index--J3eexb7.js 2>&1

# 6. Check n8n container logs
echo ""
echo "[6] n8n container logs (last 20 lines):"
echo "----------------------------------------"
docker logs tiktok-clips-n8n --tail 20 2>&1 || echo "Container not running or logs unavailable"

# 7. Check docs container
echo ""
echo "[7] docs container status:"
echo "----------------------------------------"
docker ps | grep -E "docs|nginx" || echo "docs container not running"
docker logs tiktok-clips-docs --tail 10 2>&1 || echo "docs container logs unavailable"

# 8. Check file exists in n8n
echo ""
echo "[8] Check if JS file exists in n8n container:"
echo "----------------------------------------"
docker exec tiktok-clips-n8n ls -la /data 2>&1 | head -10 || echo "Cannot check /data"
docker exec tiktok-clips-n8n find / -name "*.js" 2>&1 | head -5 || echo "Cannot find JS files"

# 9. Check Caddy logs
echo ""
echo "[9] Caddy logs (last 30 lines):"
echo "----------------------------------------"
docker logs tiktok-clips-caddy --tail 30 2>&1

# 10. Network connectivity
echo ""
echo "[10] Network test from Caddy to n8n:"
echo "----------------------------------------"
docker exec tiktok-clips-caddy ping -c 1 n8n 2>&1 || echo "Ping failed"
docker exec tiktok-clips-caddy curl -s -o /dev/null -w "Caddy->n8n Status: %{http_code}\n" http://n8n:5678/ 2>&1 || echo "Connection test failed"

echo ""
echo "================================================================"
echo "  DIAGNOSTIC COMPLETE"
echo "================================================================"