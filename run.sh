#!/bin/sh
set -eu

OPTIONS=/data/options.json
if [ ! -f "$OPTIONS" ]; then
  echo "Missing $OPTIONS; Home Assistant did not provide add-on options" >&2
  exit 1
fi

export WAHA_LOCAL_STORE_BASE_DIR=/data/.sessions
export WHATSAPP_API_PORT=3000
export WHATSAPP_DEFAULT_ENGINE="$(node -e 'const o=require(process.argv[1]); process.stdout.write(o.engine || "GOWS")' "$OPTIONS")"
export WAHA_PRINT_QR="$(node -e 'const o=require(process.argv[1]); process.stdout.write(String(o.print_qr ?? false))' "$OPTIONS")"
export TZ="$(node -e 'const o=require(process.argv[1]); process.stdout.write(o.timezone || "Europe/London")' "$OPTIONS")"

api_key=$(node -e 'const o=require(process.argv[1]); process.stdout.write(o.api_key || "")' "$OPTIONS")
dashboard_user=$(node -e 'const o=require(process.argv[1]); process.stdout.write(o.dashboard_username || "admin")' "$OPTIONS")
dashboard_password=$(node -e 'const o=require(process.argv[1]); process.stdout.write(o.dashboard_password || "")' "$OPTIONS")
swagger_user=$(node -e 'const o=require(process.argv[1]); process.stdout.write(o.swagger_username || "admin")' "$OPTIONS")
swagger_password=$(node -e 'const o=require(process.argv[1]); process.stdout.write(o.swagger_password || "")' "$OPTIONS")
swagger_enabled=$(node -e 'const o=require(process.argv[1]); process.stdout.write(String(o.swagger_enabled ?? false))' "$OPTIONS")

if [ -z "$api_key" ] || [ -z "$dashboard_password" ]; then
  echo "WAHA is not configured yet. Open Settings > Apps > WAHA (improved) and set an API key and dashboard password." >&2
  exit 1
fi

export WAHA_API_KEY="$api_key"
export WAHA_DASHBOARD_ENABLED=true
export WAHA_DASHBOARD_USERNAME="$dashboard_user"
export WAHA_DASHBOARD_PASSWORD="$dashboard_password"
export WHATSAPP_SWAGGER_ENABLED="$swagger_enabled"
export WHATSAPP_SWAGGER_USERNAME="$swagger_user"
export WHATSAPP_SWAGGER_PASSWORD="$swagger_password"

onboard_pid=''
trap '[ -n "$onboard_pid" ] && kill "$onboard_pid" 2>/dev/null || true' EXIT INT TERM

/entrypoint.sh "$@" &
app_pid=$!
node /usr/local/bin/waha-ha-onboard.js &
onboard_pid=$!

wait "$app_pid"
