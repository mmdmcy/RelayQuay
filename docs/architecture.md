# Architecture

RelayQuay publishes narrow private service surfaces through Cloudflare Tunnel.
Its primary profile proxies RustOpViewer as a loopback HTTP/WebSocket app. It
can also proxy a generic private app or the RustDesk WebSocket surface needed by
browser clients. It does not publish app listeners or raw RustDesk TCP/UDP
ports to the Internet.

```text
browser
  -> Cloudflare Access
  -> Cloudflare Tunnel
  -> loopback Caddy gateway
  -> hbbs WebSocket and hbbr WebSocket
```

RustOpViewer/private app mode uses two hostnames:

```text
public cover hostname
  -> Cloudflare Tunnel
  -> loopback Caddy 404 cover response

protected app hostname
  -> Cloudflare Access
  -> Cloudflare Tunnel
  -> loopback Caddy gateway
  -> private HTTP/WebSocket app on loopback
```

Transport profiles can replace Cloudflare as long as they target the same
loopback gateway:

```text
remote client
  -> selected transport
  -> http://127.0.0.1:8788
  -> RelayQuay Caddy gateway
```

## Components

- `cloudflared` creates an outbound-only tunnel to Cloudflare.
- Cloudflare Access authenticates users before requests reach protected
  hostnames.
- Caddy listens on loopback and proxies either `/ws/id` and `/ws/relay`, or a
  configured app upstream when the protected app Host matches.
- Cover mode returns a neutral `404 Not Found` instead of proxying an upstream.
- Optional static web assets can be served from `RELAYQUAY_WEBCLIENT_PATH`.
- RustDesk raw ports remain private to loopback, VPN, LAN, or explicit firewall
  allowlists.
- Deployment files live under `deploy/` so runtime configuration is separated
  from docs, examples, and infrastructure templates.
- Transport-specific guidance lives in [Transports](transports.md),
  [Onion Service](onion-service.md), and [VPS Transport](vps-transport.md).

## Runtime State

Private state belongs outside the repository, normally under
`/var/lib/relayquay`.

That includes tunnel tokens, real hostnames, RustDesk keys, generated web-client
assets, logs, databases, and host-specific firewall notes.

## Decisions

- [0001: Cloudflare Access and Tunnel](adr/0001-cloudflare-access-and-tunnel.md)
- [0002: Subdomain With Optional Path Redirect](adr/0002-subdomain-with-optional-path-redirect.md)
- [0003: Cover and Protected App Hostnames](adr/0003-cover-and-protected-app-hostnames.md)
- [0004: Transport Profiles](adr/0004-transport-profiles.md)
