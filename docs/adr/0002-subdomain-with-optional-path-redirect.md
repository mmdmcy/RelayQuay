# 0002: Subdomain With Optional Path Redirect

## Status

Accepted.

## Context

Operators often want a friendly path such as `/sky` on an existing website. A
Cloudflare Tunnel public hostname routes an entire hostname to a tunnel. It does
not safely take over one path of an existing Pages or origin site by itself.

## Decision

RelayQuay treats the protected service hostname as its own hostname, for
example `rustdesk-wss.example.com`. Operators may add an external redirect from
an existing site path, such as `/sky`, to the protected hostname.

## Consequences

- The existing website remains independent.
- The protected hostname can have a simple Access policy covering all paths,
  including `/ws/id` and `/ws/relay`.
- A same-origin path proxy is possible, but it requires additional Worker,
  Pages, or edge-routing design and is intentionally outside the default path.
