#!/bin/bash
# Diagnostic: Why n8n JS assets return empty MIME type
# Run on the droplet terminal

echo "============================================"
echo "  DIAGNOSTIC: n8n blank page / MIME type issue"
echo "============================================"
echo ""

echo "--- 1. Is DOMAIN set in .env? ---"
cd /opt/tiktok-clips/TikTokBPlan 2>/dev/null || cd /opt/tiktok-clips/TikTokBPlan
cat .env 2>/dev/null | grep -E '^(DOMAIN|CADDY_EMAIL|N8N_HOST)' || echo ".env not found or missing DOMAIN/CADDY_EMAIL"
echo ""

echo "--- 2. Is DOMAIN exported in shell? ---"
echo "DOMAIN=$DOMAIN"
echo "CADDY_EMAIL=$CADDY_EMAIL"
echo ""

echo "--- 3. n8n environment variables (from running container) ---"
docker exec tiktok-clips-n8n env | grep -E '^(N8N_HOST|N8N_PORT|N8N_PROTOCOL|WEBHOOK_URL|DOMAIN)' 2>/dev/null || echo "n8n container not running"
echo ""

echo "--- 4. Fetch n8n homepage HTML and check asset URLs ---"
curl -s http://localhost:5678/ | grep -oE '(src|href)="[^"]*\.js[^"]*"|(src|href)="[^"]*\.css[^"]*"' | head -20
echo ""

echo "--- 5. Try fetching one of those asset URLs directly ---"
ASSET_URL=$(curl -s http://localhost:5678/ | grep -oE 'src="[^"]*\.js[^"]*"' | head -1 | sed 's/src="//;s/"//')
if [ -n "$ASSET_URL" ]; then
  echo "Asset URL: $ASSET_URL"
  curl -s -o /dev/null -w "HTTP %{http_code}, Content-Type: %{content_type}, Size: %{size_download}\n" "http://localhost:5678$ASSET_URL"
else
  echo "No asset URLs found in HTML"
fi
echo ""

echo "--- 6. Check Caddy is proxying correctly ---"
curl -sk -o /dev/null -w "Caddy HTTPS: %{http_code}, Type: %{content_type}\n" https://claudinesclip.online/ 2>/dev/null || echo "Domain not reachable"
echo ""

echo "============================================"
echo "  FIX COMMANDS (run these if DOMAIN not set):"
echo "============================================"
echo "export DOMAIN=claudinesclip.online"
echo "export CADDY_EMAIL=your-real-email@example.com"
echo "grep -q '^DOMAIN=' .env || echo \"DOMAIN=\$DOMAIN\" >> .env"
echo "grep -q '^CADDY_EMAIL=' .env || echo \"CADDY_EMAIL=\$CADDY_EMAIL\" >> .env"
echo "docker compose up -d caddy n8n"
echo "============================================"
