# RustOpViewer

RustOpViewer is RelayQuay's primary private-app profile. RustOpViewer runs as a
separate host process on loopback; RelayQuay supplies the loopback Caddy
gateway, cover state, and remote transport.

```text
browser
  -> Cloudflare Access protected hostname
  -> Cloudflare Tunnel
  -> RelayQuay on 127.0.0.1:8788
  -> RustOpViewer on 127.0.0.1:45080
```

## Security Boundary

Cloudflare Access and RustOpViewer enforce different layers:

- Access authenticates an identity before a request reaches the host.
- RustOpViewer approves a browser with a one-time host-generated pairing code
  or an explicitly configured unattended login.
- RustOpViewer owns short-lived sessions, remembered-browser trust, remote
  input scopes, view-only mode, revocation, and panic stop.
- RelayQuay does not read or store pairing codes, sessions, remembered-browser
  records, access passwords, or admin tokens.

Passing Access is not a RustOpViewer pairing. Keep both layers enabled.

## Configure RelayQuay

Start from the fail-closed profile:

```bash
./bin/relayquay init
install -m 600 examples/rustopviewer/relayquay.env.example \
  /var/lib/relayquay/relayquay.env
```

Replace the example hostnames and tunnel token in the private copy. The core
settings are:

```bash
RELAYQUAY_GATEWAY=rustopviewer
RELAYQUAY_MODE=cover
RELAYQUAY_PUBLIC_HOST=relayquay-cover.example.com
RELAYQUAY_APP_HOST=rov.example.com
RELAYQUAY_APP_UPSTREAM=127.0.0.1:45080
```

Route both hostnames through the same tunnel to `http://127.0.0.1:8788`.
Attach Cloudflare Access only to `RELAYQUAY_APP_HOST`. Requests for the public
cover or an unknown hostname receive a plain `404 Not Found`.

The protected hostname exposes RelayQuay's own `/healthz` and
`/.well-known/relayquay` checks without forwarding them to RustOpViewer.

## Run and Pair RustOpViewer

Keep RustOpViewer on its default loopback listener. A source checkout can run
headlessly with:

```bash
cargo run --release -- --headless
```

For a new browser, generate a one-time pairing code on the host. Current
RustOpViewer builds can request one from an already running host:

```bash
rustopviewer --generate-pair-code
```

For an intentional first headless launch, `--headless --print-pair-code` emits
one startup code to the host log. Treat that output as private and short-lived.
A remembered browser can restore a new short-lived session only while its
host-side trust record remains valid. Revoke remembered browsers or use panic
stop from RustOpViewer when a client is lost or no longer trusted.

## Activate and Operate

The RustOpViewer profile starts covered. Check both local services before
activation:

```bash
./bin/relayquay doctor
./bin/relayquay up
./bin/relayquay activate
```

Operational states are explicit:

- `activate` proxies only the configured protected app hostname.
- `cover` keeps the tunnel running but returns only the neutral cover response.
- `pause` selects cover mode and stops the Cloudflare connector.

Use RustOpViewer's host controls for view-only mode, session revocation, input
authorization, and panic stop. RelayQuay intentionally does not duplicate
those controls.

## Legacy Configuration Migration

The earlier RustOpViewer-only draft used `ROV_UPSTREAM` and one hostname. The
helper recognizes that variable, selects the RustOpViewer gateway, and defaults
the migrated config to cover mode. Migrate it explicitly:

```bash
RELAYQUAY_GATEWAY=rustopviewer
RELAYQUAY_APP_UPSTREAM="${ROV_UPSTREAM:-127.0.0.1:45080}"
RELAYQUAY_APP_HOST=rov.example.com
```

For a one-host migration, `RELAYQUAY_APP_HOST` may equal the old
`RELAYQUAY_PUBLIC_HOST`, but that hostname must remain protected by Access and
there is no anonymous cover while active. Prefer separate cover and protected
hostnames for new deployments. Remove `ROV_UPSTREAM` after the private env has
been migrated.

## Private Material and Network Use

Do not commit RustOpViewer pairing codes, session or remembered-browser state,
access passwords, admin tokens, screen captures, logs, or real hostnames. Keep
RustOpViewer state and RelayQuay's env file outside both source checkouts.

On metered connections, use RustOpViewer's Data Saver or Emergency stream
profile and stop `cloudflared` when remote access is unnecessary:

```bash
./bin/relayquay stop cloudflared
./bin/relayquay up cloudflared
```

See [Firewall](firewall.md), [Network Usage](network-usage.md), and
[Threat Model](threat-model.md).
