# VPS Tunnel Transport

VPS tunnel mode is the non-Cloudflare option for normal browsers. RelayQuay
still runs on the private host, but a VPS acts as the public edge that you
control.

This profile is not implemented as a ready-to-run Compose stack yet. The target
shape is:

```text
browser
  -> VPS Caddy or nginx with TLS and auth
  -> WireGuard or SSH reverse tunnel
  -> private host loopback RelayQuay gateway
  -> RustDesk WSS or private app upstream
```

## Why It Exists

Compared with Cloudflare Tunnel:

- You control the edge server.
- A normal browser can connect without Tor Browser.
- No router port forward is needed on the private host.

Costs:

- You maintain a VPS.
- You need TLS, authentication, firewall, updates, and monitoring on the VPS.
- Misconfiguration can expose the service.

## Future Work

A future RelayQuay VPS profile should provide:

- Minimal VPS Caddy config.
- WireGuard tunnel example.
- SSH reverse tunnel fallback.
- Health checks from VPS to private host.
- Clear secret and key rotation steps.
