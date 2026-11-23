#!/bin/bash
# Diagnostic script for n8n + Caddy blank page issue
# Run on the droplet: ssh root@138.68.242.71 then paste this

set -e

echo "============================================"
echo "  DIAGNOSTIC: n8n + Caddy Blank Page Issue"
echo "============================================"
echo ""

echo "--- 1. Container Status ---"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
echo ""

echo "--- 2. n8n Direct Test (port 5678) ---"
curl -s -o /dev/null -w "n8n HTTP code: %{http_code}\n" http://localhost:5678/ 2>&1 || echo "n8n: CONNECTION REFUSED"
echo ""

echo "--- 3. Caddy Direct Test (port 80/443) ---"
curl -sk -o /dev/null -w "Caddy HTTPS code: %{http_code}\n" https://localhost/ 2>&1 || echo "Caddy: CONNECTION REFUSED"
echo ""

echo "--- 4. n8n Container Logs (last 25 lines) ---"
docker logs tiktok-clips-n8n --tail 25 2>&1 || echo "n8n container not found"
echo ""

echo "--- 5. Caddy Container Logs (last 25 lines) ---"
docker logs tiktok-clips-caddy --tail 25 2>&1 || echo "caddy container not found"
echo ""

echo "--- 6. Docker Compose Config ---"
cd /opt/tiktok-clips/TikTokBPlan 2>/dev/null && docker compose config --services 2>&1 || echo "compose not found"
echo ""

echo "============================================"
echo "  END OF DIAGNOSTIC"
echo "============================================"
