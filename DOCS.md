# WAHA (improved)

Open the app configuration before starting it and set:

- **API key** — send as `X-Api-Key` on REST requests.
- **Dashboard password** — used at `/dashboard`.
- **Swagger** — disabled by default; enable only when needed.

The dashboard is available at `http://<home-assistant-ip>:3000/dashboard`.
Existing WAHA session data remains under `/data/.sessions` and is preserved across restarts.

This wrapper configures authentication and onboarding only; GOWS storage behavior remains governed by the upstream WAHA image.
## Onboarding

Configure the add-on from Home Assistant's app options. The session name is
user-selectable and defaults to `default`; it is not tied to any particular
phone, person, or integration. Existing sessions are preserved. When enabled,
the add-on applies the selected GOWS storage flags to the named session and
starts it if it is stopped.

The storage flags are applied per WAHA session. They control WAHA's GOWS
storage options for messages, groups, chats, labels, contacts, and message
secrets. Changing the session name lets one installation manage multiple
WhatsApp accounts without sharing configuration between them.
