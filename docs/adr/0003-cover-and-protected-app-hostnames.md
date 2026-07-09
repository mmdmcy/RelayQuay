# 0003: Cover and Protected App Hostnames

## Status

Accepted.

## Context

Cloudflare Access redirects are visible before a request reaches the origin. If
Access is attached to a public cover hostname, anonymous users can infer that
the hostname protects an application even when the local origin would otherwise
serve a neutral response.

RelayQuay also needs to support generic loopback HTTP/WebSocket applications,
including tools that operators run separately from this repository.

## Decision

RelayQuay supports a private app gateway mode with two hostnames:

- A public cover hostname routed to Caddy without Cloudflare Access.
- A separate protected app hostname routed to Caddy with Cloudflare Access.

Caddy proxies the private upstream only when the request Host matches the
protected app hostname. All other hosts receive a plain `404 Not Found`.

## Consequences

- The public hostname does not expose a Cloudflare Access login redirect.
- The protected app hostname can keep normal Cloudflare Access controls.
- RelayQuay can front apps such as RustOpViewer without bundling them.
- Operators must keep the two hostnames distinct in Cloudflare and in the
  private env file.
