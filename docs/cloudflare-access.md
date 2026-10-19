# Cloudflare Access

RelayQuay uses Cloudflare Tunnel as the public transport and Cloudflare Access
as the authenticated front door for protected hostnames. Do not attach Access
to a public cover hostname; Access redirects are visible before the request can
reach the local cover response.

## Tunnel

Create a Cloudflare Tunnel and route each RelayQuay hostname to the local Caddy
gateway:

```text
Hostname: rustdesk-wss.example.com
Service:  http://127.0.0.1:8788
```

For RustOpViewer/private HTTP app mode, route both the public cover hostname
and the protected app hostname to the same service:

```text
Hostname: relayquay-public.example.com
Service:  http://127.0.0.1:8788

Hostname: relayquay-private.example.com
Service:  http://127.0.0.1:8788
```

The compose file uses a tunnel token through `CLOUDFLARE_TUNNEL_TOKEN`. Keep
that token only in `/var/lib/relayquay/relayquay.env`, or in another private
env file selected with `RELAYQUAY_ENV_FILE`. cloudflared receives it as the
`TUNNEL_TOKEN` environment variable, never as a command-line argument, and
`relayquay config` redacts it.

## Access Application

For RustDesk WSS mode, create a Cloudflare Access self-hosted application for
the WSS hostname:

```text
Application domain: rustdesk-wss.example.com
Policy action:      Allow
Include:            your email address or your identity group
Session duration:   short enough for your risk tolerance
```

For RustOpViewer/private HTTP app mode, create the Access application for
`RELAYQUAY_APP_HOST`, not `RELAYQUAY_PUBLIC_HOST`:

```text
Application domain: relayquay-private.example.com
Policy action:      Allow
Include:            your email address or your identity group
Session duration:   short enough for your risk tolerance
```

For personal use, Cloudflare One-time PIN is low-friction. A real identity
provider with MFA is stronger.

In RustDesk WSS mode the local Caddy gateway adds a second layer: it only
serves `/ws/id`, `/ws/relay`, and the optional web client to requests whose
`Host` is `RELAYQUAY_PUBLIC_HOST` and that carry the `Cf-Access-Jwt-Assertion`
header Access injects after login. Any other hostname routed to the same
origin, or a request without that header, gets the neutral `404 Not Found`.
This is a presence check (full JWT verification needs a Caddy plugin), so the
Access policy at the edge stays the real control. Keep cloudflared's default
of forwarding the original `Host` header; an "HTTP Host Header" override in
the tunnel's origin settings would make the gateway refuse everything.

## Browser Flow

Cloudflare Access protects the WebSocket handshake. Before using
`https://rustdesk.com/web`, visit:

```text
https://rustdesk-wss.example.com/healthz
```

After Access authentication succeeds, the browser has the Access session cookie
for your hostname. Then open RustDesk Web and configure your self-hosted server.

For RustOpViewer/private HTTP app mode, first open the protected `/healthz`
endpoint to establish the Access session and verify RelayQuay. Then open the
app root. The public cover hostname should continue to return a plain `404 Not
Found`.

## CORS and Cookies

If the web client cannot connect after Access login, check the Access
application's additional settings:

- The hostname must match exactly.
- The Access session cookie must be available to the browser profile using
  RustDesk Web.
- If you enable CORS controls in Cloudflare Access, allow
  `https://rustdesk.com` as an origin.

## Why Not Cloudflare Arbitrary TCP

Cloudflare Access can proxy arbitrary TCP, but that mode requires `cloudflared`
on the client device. That does not fit a browser-only `rustdesk.com/web` flow.
RelayQuay uses normal HTTPS and WebSocket support so the client side can remain
just a browser.
