# WAHA for Home Assistant (slim, aarch64)

A Home Assistant app wrapping [WAHA](https://waha.devlike.pro) (GOWS engine):
`run.sh` maps the app options to WAHA's environment and `onboard.js` applies
the session's storage settings. The image is built from
`devlikeapro/waha:gows-arm-*`, pruned of other platforms' native binaries and
build tooling (`prune.sh`, about 0.8 GB less), flattened, boot-tested and
published to `ghcr.io/26tajeen/waha-ha-aarch64:<version>` by CI.

Bump `version` in `config.json` for every change; CI refuses to overwrite a
published tag.
