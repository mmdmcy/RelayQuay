# RelayQuay

RelayQuay is a RustOpViewer-first deployment kit for exposing private
remote-access services through a loopback gateway and selectable transports
without publishing raw service ports to the Internet. It also supports generic
private HTTP/WebSocket apps and the original RustDesk WebSocket gateway.
RelayQuay does not bundle those tools; it provides the local Caddy gateway,
transport guidance, and fail-closed operational modes.

The primary RustOpViewer profile keeps both services on loopback:

```text
browser
  -> protected app hostname
  -> Cloudflare Access
  -> Cloudflare Tunnel
  -> RelayQuay on 127.0.0.1:8788
  -> RustOpViewer on 127.0.0.1:45080
```

Cloudflare Access is the outer identity gate. RustOpViewer still owns
host-approved pairing, short-lived sessions, remembered-browser trust, and
remote-input authorization. RelayQuay stores none of that application state.

The recommended layout adds a separate public cover hostname:

```text
public cover hostname
  -> Cloudflare Tunnel
  -> loopback Caddy cover response

protected app hostname
  -> Cloudflare Access
  -> Cloudflare Tunnel
  -> loopback Caddy reverse proxy
  -> RustOpViewer or another private app on 127.0.0.1
```

The public cover hostname should not have a Cloudflare Access application
attached. Otherwise anonymous requests can discover the Access login endpoint
before the request reaches Caddy.

RelayQuay is transport-oriented. Cloudflare Tunnel is the easiest transport,
but the local gateway can also be used behind an onion service or an
operator-owned VPS tunnel. See [docs/transports.md](docs/transports.md).

## Why This Exists

A browser remote-control app should not need a wildcard listener or a set of
raw public service ports just to be reachable away from home. RelayQuay gives
RustOpViewer a narrow loopback reverse proxy, an authenticated transport, and
explicit active, cover, and paused states. Its RustDesk profile similarly
publishes only the WebSocket surface needed by browser clients.

Everything sensitive stays outside the repo, normally under
`/var/lib/relayquay`.

Runtime files are grouped under `deploy/`; day-to-day operation goes through
`./bin/relayquay`.

## Quick Start

Create private state, then install the fail-closed RustOpViewer profile:

```bash
./bin/relayquay init
install -m 600 examples/rustopviewer/relayquay.env.example \
  /var/lib/relayquay/relayquay.env
```

Edit `/var/lib/relayquay/relayquay.env` and set:

- `RELAYQUAY_PUBLIC_HOST`
- `RELAYQUAY_APP_HOST`
- `RELAYQUAY_APP_UPSTREAM` if RustOpViewer is not on `127.0.0.1:45080`
- `CLOUDFLARE_TUNNEL_TOKEN`

Run RustOpViewer separately on loopback. For a source checkout:

```bash
cd /path/to/rustopviewer
cargo run --release -- --headless
```

The profile starts in cover mode. Verify it, bring up the neutral cover, and
activate the protected app only after the tunnel and Access policy are ready:

```bash
./bin/relayquay doctor
./bin/relayquay up
./bin/relayquay activate
./bin/relayquay logs
```

Opening the protected hostname does not bypass RustOpViewer security. A new
browser still needs a host-generated one-time pairing code, an approved
unattended login, or remembered trust that has not been revoked. See the
[RustOpViewer guide](docs/rustopviewer.md).

## RustOpViewer and Private App Modes

RustOpViewer has a first-class gateway name; `app` remains available for other
loopback HTTP/WebSocket services:

```bash
RELAYQUAY_GATEWAY=rustopviewer
RELAYQUAY_PUBLIC_HOST=relayquay-public.example.com
RELAYQUAY_APP_HOST=rov.example.com
RELAYQUAY_APP_UPSTREAM=127.0.0.1:45080
```

Route both hostnames to the same Cloudflare Tunnel. Attach Cloudflare Access
only to `RELAYQUAY_APP_HOST`; leave `RELAYQUAY_PUBLIC_HOST` as the neutral
cover hostname. In active mode, Caddy serves the upstream only for
`RELAYQUAY_APP_HOST` and returns a plain `404 Not Found` for all other hosts.

```bash
./bin/relayquay activate
./bin/relayquay cover
./bin/relayquay pause
```

`activate` serves the configured gateway. `cover` keeps the tunnel running but
serves only the neutral cover response. `pause` configures cover mode and stops
the Cloudflare connector.

Existing RustOpViewer deployments may temporarily keep `ROV_UPSTREAM`; the
helper maps it to `RELAYQUAY_APP_UPSTREAM` and reports the migration in
`doctor`. A legacy config with no explicit gateway starts in cover mode and
must set `RELAYQUAY_APP_HOST` before activation. The app hostname may equal the
old `RELAYQUAY_PUBLIC_HOST` for a one-host migration, but the two-host layout is
recommended because it keeps the public cover hostname free of Access
redirects.

See [docs/rustopviewer.md](docs/rustopviewer.md) and
[docs/private-http-app.md](docs/private-http-app.md).

## RustDesk WebSocket Profile

The backwards-compatible root `.env.example` remains the RustDesk profile. It
proxies only `/ws/id`, `/ws/relay`, and the health endpoint. RustDesk's normal
TCP/UDP ports should remain private to localhost, LAN, Tailscale, WireGuard, or
another explicitly allowed network.

```bash
RELAYQUAY_GATEWAY=rustdesk
./bin/relayquay doctor
./bin/relayquay up
```

To run the optional RustDesk OSS containers as well:

```bash
COMPOSE_PROFILES=server ./bin/relayquay up
```

See [docs/rustdesk-web.md](docs/rustdesk-web.md).

## Transport Options

- Cloudflare Tunnel: easiest normal-browser setup, but Cloudflare is in the
  request path.
- Onion service: no Cloudflare, no DNS, and no inbound ports, but requires Tor
  Browser or a Tor client and should use onion client authorization.
- VPS tunnel: future normal-browser option through an operator-owned edge.

See [docs/onion-service.md](docs/onion-service.md) and
[docs/vps-transport.md](docs/vps-transport.md).

## Cloudflare Setup

1. Create a Cloudflare Tunnel for the cover and protected app hostnames.
2. Route both hostnames to `http://127.0.0.1:8788`.
3. Create Cloudflare Access only for the protected app hostname, not the public
   cover hostname.
4. For RustDesk WSS mode, use one Access-protected WSS hostname instead.
5. Add an allow policy for only your email address or identity group.
6. Enable an MFA-capable identity provider, or Cloudflare One-time PIN for a
   low-friction personal setup.
7. Open the protected `/healthz` endpoint to establish the Access session and
   verify RelayQuay without sending the request to RustOpViewer.
8. Open the protected app root and complete RustOpViewer pairing. In RustDesk
   mode, open `https://rustdesk.com/web` and configure the WSS hostname.

See [docs/cloudflare-access.md](docs/cloudflare-access.md) and
[docs/rustdesk-web.md](docs/rustdesk-web.md) for the details and caveats.

## Optional Own-Domain Web Client

RelayQuay can also serve a self-hosted RustDesk web client from your own
Access-protected domain. This is opt-in and uses web assets you provide:

```bash
RELAYQUAY_WEBCLIENT=1
RELAYQUAY_WEBCLIENT_PATH=/sky
RUSTDESK_WEB_ROOT=/var/lib/relayquay/webclient
```

When enabled, `/sky/` serves the static web client while `/ws/id` and
`/ws/relay` continue to proxy RustDesk WebSocket traffic. RelayQuay
intentionally does not bundle or fetch RustDesk's hosted web app. See
[docs/web-client.md](docs/web-client.md).

For a dedicated protected hostname, set `RELAYQUAY_WEBCLIENT_PATH=/` to serve
the web client at the hostname root.

## Security Defaults

- No Cloudflare token is committed, and the runtime token reaches cloudflared
  only as an environment variable; `relayquay config` redacts it.
- No real hostname is committed.
- In rustdesk mode the gateway serves only `RELAYQUAY_PUBLIC_HOST` requests
  that carry the Cloudflare Access `Cf-Access-Jwt-Assertion` header.
- Optional web-client assets are private operator-supplied files.
- The gateway binds to `127.0.0.1:8788`.
- RustOpViewer/private app upstreams should bind to loopback too.
- Pairing codes, browser sessions, remembered trust, and admin credentials stay
  in RustOpViewer's private state, never RelayQuay or Git.
- The RustDesk server profile uses Docker host networking only when you opt in.
- Firewall examples deny public access to `8788`, the app port, and
  `21115-21119`, with deliberate private-network exceptions.
- The helper script refuses to print Cloudflare secrets.

## Network Usage

RelayQuay is quiet while idle. The main bandwidth cost is the active desktop
stream, not the gateway itself. For metered Wi-Fi, keep Cloudflare Access
enabled, stop the tunnel when you do not need browser access, and use
RustOpViewer's Data Saver or Emergency profile. RustDesk users can lower
quality, resolution, and frame rate.

```bash
./bin/relayquay stop cloudflared
./bin/relayquay up cloudflared
```

See [docs/network-usage.md](docs/network-usage.md).

## Browser Relay Note

If an existing `hbbs` advertises a relay address that only works on a private
network, the RustDesk Web session may signal successfully and then time out
during relay setup. For browser use, the relay address visible to the web client
must also be reachable through the WSS hostname, or the web client must be
configured to use that hostname for both ID and relay where the UI supports it.

## Plugroot

RelayQuay is standalone. If you also use Plugroot, register this standalone
checkout as a managed `[[repo]]` and monitor its loopback port as a manual
service using
[examples/plugroot/plugroot.local.example.toml](examples/plugroot/plugroot.local.example.toml).
`plugroot repos sync` owns checkout updates; `bin/relayquay` remains the
lifecycle authority because it selects active, cover, RustOpViewer, and
RustDesk Compose variants. Keep the private env and state outside both code
checkouts.

Do not put real tunnel tokens, private hostnames, or local-only notes in this
checkout. Put those in the private env file selected by `RELAYQUAY_ENV_FILE`.

## Project Docs

- [Architecture](docs/architecture.md)
- [Cloudflare Access](docs/cloudflare-access.md)
- [Firewall](docs/firewall.md)
- [Infrastructure](docs/infrastructure.md)
- [Network Usage](docs/network-usage.md)
- [Onion Service](docs/onion-service.md)
- [Operations](docs/operations.md)
- [Private HTTP App](docs/private-http-app.md)
- [Repository Layout](docs/repository-layout.md)
- [RustOpViewer](docs/rustopviewer.md)
- [Threat Model](docs/threat-model.md)
- [Transports](docs/transports.md)
- [VPS Transport](docs/vps-transport.md)
