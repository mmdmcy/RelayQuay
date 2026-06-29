# 0001: Cloudflare Access and Tunnel

## Status

Accepted.

## Context

RustDesk Web needs WebSocket Secure access to a self-hosted RustDesk server, but
publishing raw RustDesk TCP/UDP ports broadly increases exposure.

## Decision

RelayQuay publishes a narrow HTTPS hostname through Cloudflare Tunnel and puts
Cloudflare Access in front of it. The tunnel connects outbound from the host.
Access authenticates users before traffic reaches the tunnel.

## Consequences

- No inbound firewall opening is required for browser access.
- The host still needs outbound access to Cloudflare.
- Cloudflare can observe traffic metadata.
- RustDesk device passwords, approvals, and server key verification are still
  required controls.
