#!/usr/bin/env bash
# ==============================================================================
# One-shot health check for the droplet (replaces diagnose-droplet/-full/-mime.sh)
# Run ON the droplet:   bash /opt/tiktok-clips/TikTokBPlan/diagnose.sh
# Read-only: changes nothing.
# ==============================================================================
cd "$(dirname "$0")" 2>/dev/null
[ -f docker-compose.yml ] || cd /opt/tiktok-clips/TikTokBPlan || exit 1
DOMAIN=$(grep -E '^DOMAIN=' .env 2>/dev/null | cut -d= -f2)
hr(){ echo; echo "--- $1 ---"; }

echo "Project: $(pwd)   Domain: ${DOMAIN:-<DOMAIN missing in .env>}"

hr "1. Containers"
docker ps --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}'

hr "2. n8n env (inside container)"
docker exec tiktok-clips-n8n env 2>/dev/null | grep -E '^(N8N_HOST|N8N_PROTOCOL|WEBHOOK_URL|CLIP_WINDOW|TIKTOK_PRIVACY_LEVEL)=' || echo "n8n container not running"

hr "3. Tools inside n8n image"
for t in ffmpeg yt-dlp whisper-cli python3 aws; do
  docker exec tiktok-clips-n8n sh -c "command -v $t" >/dev/null 2>&1 && echo "  ok   $t" || echo "  MISSING $t"
done
docker exec tiktok-clips-n8n ls /models 2>/dev/null | grep -q ggml && echo "  ok   whisper model" || echo "  MISSING whisper model in ./models"

hr "4. n8n direct (port 5678)"
curl -s -o /dev/null -w "  / -> HTTP %{http_code}\n" http://localhost:5678/ || echo "  n8n: connection refused"
ASSET=$(curl -s http://localhost:5678/ | grep -oE 'src="[^"]*\.js"' | head -1 | sed 's/src="//;s/"//')
[ -n "$ASSET" ] && curl -s -o /dev/null -w "  $ASSET -> HTTP %{http_code}, %{content_type}, %{size_download} B\n" "http://localhost:5678$ASSET"

hr "5. Through Caddy (HTTPS)"
if [ -n "$DOMAIN" ]; then
  curl -sk -o /dev/null -w "  / -> HTTP %{http_code}, %{content_type}\n" "https://$DOMAIN/"
  [ -n "$ASSET" ] && curl -sk -o /dev/null -w "  asset -> HTTP %{http_code}, %{content_type}, %{size_download} B  (0 B = Caddy routing bug)\n" "https://$DOMAIN$ASSET"
  for p in privacy terms data-usage app-description; do
    curl -sk -o /dev/null -w "  /$p -> HTTP %{http_code}\n" "https://$DOMAIN/$p"
  done
fi

hr "6. Caddyfile sanity"
grep -qE 'handle / *\{' Caddyfile && echo "  PROBLEM: 'handle / {' found -> only '/' is proxied, JS assets break. Use bare 'handle {'." || echo "  ok   catch-all handle"
grep -q '\${YOUR_DOMAIN}' Caddyfile && echo "  NOTE: Caddyfile is still the template -> run deploy-droplet.sh to render it" || true

hr "7. Disk"
df -h / | tail -1
du -sh temp output 2>/dev/null

hr "8. Last logs"
for c in tiktok-clips-n8n tiktok-clips-caddy tiktok-clips-docs; do
  echo "[$c]"; docker logs "$c" --tail 15 2>&1 | sed 's/^/  /'
done
echo; echo "=== done ==="
