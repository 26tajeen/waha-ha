#!/bin/sh
# Boot the built image the way HA runs it (options in /data) and check WAHA
# answers its API with the GOWS engine. Used by CI before anything is pushed.
set -eu
IMAGE=$1
d=$(mktemp -d)
cat > "$d/options.json" <<JSON
{"api_key":"ci-test-key","dashboard_username":"admin","dashboard_password":"ci-test-pass",
 "swagger_enabled":false,"swagger_username":"admin","swagger_password":"","engine":"GOWS",
 "print_qr":false,"timezone":"Europe/London","session_name":"ci","auto_start":false,
 "apply_storage_to_existing":false,"storage_messages":false,"storage_groups":false,
 "storage_chats":false,"storage_labels":false,"storage_contacts":false,"storage_message_secrets":false}
JSON
docker run -d --name waha-boot -p 3999:3000 -v "$d:/data" "$IMAGE" >/dev/null
trap 'docker logs waha-boot 2>&1 | tail -40; docker rm -f waha-boot >/dev/null 2>&1 || true' EXIT
for i in $(seq 1 90); do
  if out=$(curl -sf -H 'X-Api-Key: ci-test-key' http://127.0.0.1:3999/api/server/version); then
    echo "WAHA up after ${i}s: $out"
    echo "$out" | grep -q '"engine":"GOWS"'
    docker exec waha-boot sh -c 'ffmpeg -version | head -1 && node -e "require(\"sharp\"); require(\"@napi-rs/canvas\")" && test -x /app/gows'
    exit 0
  fi
  sleep 1
done
echo "WAHA did not answer within 90 s" >&2
exit 1
