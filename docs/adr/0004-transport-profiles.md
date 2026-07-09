# 0004: Transport Profiles

## Status

Accepted.

## Context

RelayQuay should be usable by people who want private remote access without
opening raw service ports. Cloudflare Tunnel is convenient, but it places
Cloudflare in the request path. Tailscale and WireGuard are strong options, but
RelayQuay should also serve users who do not want a VPN client requirement.

## Decision

RelayQuay separates the local loopback gateway from transport profiles:

- Cloudflare Tunnel for easy normal-browser access.
- Onion service for advanced no-Cloudflare, no-port-forward access through Tor.
- VPS tunnel for future normal-browser access through an operator-owned edge.

The local gateway contract remains `http://127.0.0.1:8788`.

## Consequences

- Cloudflare is a supported easy mode, not the only model.
- Onion mode must be documented with client authorization and operational
  warnings.
- VPS mode can be designed without changing the local Caddy gateway.
- Direct port forwarding remains outside the recommended defaults.
