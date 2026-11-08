#!/bin/sh
# Slim upstream WAHA (devlikeapro/waha:gows-arm-*) for a Raspberry Pi 4.
#
# The upstream image is general-purpose: native binaries for every platform,
# two copies of sharp's libvips, and the project's own build tooling. On the
# HA box that cost 2.3 GB, and because this app is built locally, every HA
# backup exported all of it (2026-11-08 one ran the SD card out of space).
#
# Removed here, and nothing else:
#   - @napi-rs/canvas-<platform> and @img/sharp[-libvips]-<platform> packages
#     for anything but linux-arm64 (this image only ever runs there);
#   - dev/build tools no runtime file requires (grep of dist + node_modules,
#     2026-11-08): @oxlint, @jest, @angular-devkit, protoc-gen-ts, grpc-tools,
#     @types.
# Kept on purpose: every engine's library (dist/core/engines/*/session.*.js
# require them at startup even when only GOWS runs), typescript (@nestjs/swagger
# loads it), ffmpeg and the system libvips (GOWS links against it).
set -eu
cd /app/node_modules
before=$(du -sm . | cut -f1)

for d in @napi-rs/canvas-*; do
  [ -e "$d" ] || continue
  case "${d#@napi-rs/}" in canvas-linux-arm64-gnu) ;; *) rm -rf "$d" ;; esac
done

for base in @img sharp/node_modules/@img; do
  [ -d "$base" ] || continue
  for d in "$base"/sharp-*; do
    [ -e "$d" ] || continue
    case "${d##*/}" in sharp-linux-arm64|sharp-libvips-linux-arm64) ;; *) rm -rf "$d" ;; esac
  done
done

rm -rf @oxlint @jest @angular-devkit protoc-gen-ts grpc-tools @types

after=$(du -sm . | cut -f1)
echo "node_modules ${before} MB -> ${after} MB"

# The native modules we kept must still load on this platform.
cd /app
node -e "require('sharp'); require('@napi-rs/canvas'); console.log('native modules load')"
