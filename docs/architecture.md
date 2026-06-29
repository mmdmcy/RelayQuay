# Architecture

RelayQuay publishes only the RustDesk WebSocket surface needed by browser
clients. It does not publish raw RustDesk TCP/UDP ports to the Internet.

```text
browser
  -> Cloudflare Access
  -> Cloudflare Tunnel
  -> loopback Caddy gateway
  -> hbbs WebSocket and hbbr WebSocket
```

## Components

- `cloudflared` creates an outbound-only tunnel to Cloudflare.
- Cloudflare Access authenticates users before requests reach the tunnel.
- Caddy listens on loopback and proxies only `/ws/id` and `/ws/relay`.
- Optional static web assets can be served from `RELAYQUAY_WEBCLIENT_PATH`.
- RustDesk raw ports remain private to loopback, VPN, LAN, or explicit firewall
  allowlists.
- Deployment files live under `deploy/` so runtime configuration is separated
  from docs, examples, and infrastructure templates.

## Runtime State

Private state belongs outside the repository, normally under
`/var/lib/relayquay`.

That includes tunnel tokens, real hostnames, RustDesk keys, generated web-client
assets, logs, databases, and host-specific firewall notes.

## Decisions

- [0001: Cloudflare Access and Tunnel](adr/0001-cloudflare-access-and-tunnel.md)
- [0002: Subdomain With Optional Path Redirect](adr/0002-subdomain-with-optional-path-redirect.md)
