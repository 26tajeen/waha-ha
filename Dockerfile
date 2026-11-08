# WAHA for Home Assistant, slimmed and flattened.
#
# Published by .github/workflows/image.yml as
# ghcr.io/26tajeen/waha-ha-aarch64:<config.json version>, which config.json
# names as the app's `image`: HA pulls it instead of building on the box, so
# HA backups no longer export the image (a pulled image can be pulled again).
# build.json still lets the box build it locally as a fallback.
ARG BUILD_FROM=devlikeapro/waha:gows-arm-2026.8.1
FROM ${BUILD_FROM} AS full
COPY prune.sh /tmp/prune.sh
RUN sh /tmp/prune.sh && rm /tmp/prune.sh
COPY run.sh /usr/local/bin/waha-ha-run
COPY onboard.js /usr/local/bin/waha-ha-onboard.js
RUN chmod 755 /usr/local/bin/waha-ha-run

# One layer: files deleted in a later layer would otherwise still be shipped.
FROM scratch
COPY --from=full / /
# = upstream's config (docker inspect, gows-arm-2026.8.1).
ENV PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin \
    NODE_VERSION=24.11.1 \
    YARN_VERSION=1.22.22 \
    PUPPETEER_SKIP_DOWNLOAD=True \
    NODE_OPTIONS=--max-old-space-size=16384 \
    WHATSAPP_DEFAULT_ENGINE=GOWS \
    WAHA_GOWS_PATH=/app/gows \
    WAHA_GOWS_SOCKET=/tmp/gows.sock \
    CHOKIDAR_USEPOLLING=1 \
    CHOKIDAR_INTERVAL=5000 \
    WAHA_ZIPPER=ZIPUNZIP \
    GODEBUG=netdns=cgo
WORKDIR /app
EXPOSE 3000
LABEL org.opencontainers.image.source="https://github.com/26tajeen/waha-ha" \
      org.opencontainers.image.description="WAHA (GOWS engine) packaged as a Home Assistant app, slimmed for linux/arm64" \
      io.hass.type="addon" io.hass.arch="aarch64"
ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/waha-ha-run"]
