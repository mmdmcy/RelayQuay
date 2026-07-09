# Transports

RelayQuay separates the local gateway from the transport that makes it
reachable. The local gateway is always Caddy on loopback. The transport decides
how a remote browser reaches that loopback gateway.

## Profiles

| Profile | Remote client | Inbound home ports | Third-party edge | Main tradeoff |
| --- | --- | --- | --- | --- |
| Cloudflare Tunnel | Normal browser | No | Cloudflare | Easiest setup, less private |
| Onion service | Tor Browser or Tor client | No | Tor network | Better privacy, slower and more advanced |
| VPS tunnel | Normal browser | No | Operator-owned VPS | More control, requires a VPS |
| Direct port forward | Normal browser | Yes | None | Simple but easy to expose incorrectly |

## Recommended Defaults

Cloudflare Tunnel remains the easy default because it works with normal
browsers, handles TLS, and requires no router changes. It is not the most
private option because Cloudflare is in the request path and sees metadata.

Onion service mode is the privacy-oriented no-port-forward option. It should be
treated as advanced mode and should use onion client authorization for private
remote-access services.

VPS tunnel mode is the likely long-term "normal browser without Cloudflare"
option. The operator owns the edge server, but setup and maintenance are
heavier than Cloudflare Tunnel.

Direct port forwarding is not recommended as a RelayQuay default.

## Local Gateway Contract

All transports should target:

```text
http://127.0.0.1:8788
```

For generic private app mode, set:

```bash
RELAYQUAY_GATEWAY=app
RELAYQUAY_APP_UPSTREAM=127.0.0.1:45080
```

Then set `RELAYQUAY_APP_HOST` to the hostname the transport presents to Caddy:

- Cloudflare app mode: the protected DNS hostname.
- Onion mode: the generated `.onion` hostname.
- VPS mode: the protected VPS hostname.
