# Private HTTP App Mode

RelayQuay can front a loopback-only HTTP or WebSocket application through a
supported transport. RustOpViewer has the first-class `rustopviewer` profile;
use `app` for other services. RelayQuay does not include, download, or manage
the upstream application. See [RustOpViewer](rustopviewer.md) for pairing and
migration guidance specific to that profile.

## Hostnames

Use two hostnames:

- `RELAYQUAY_PUBLIC_HOST`: public cover hostname. Do not attach Cloudflare
  Access to this hostname.
- `RELAYQUAY_APP_HOST`: protected app hostname. Attach Cloudflare Access here.

Both hostnames can route to the same Cloudflare Tunnel service:

```text
Service: http://127.0.0.1:8788
```

Caddy only proxies the upstream when the request Host matches
`RELAYQUAY_APP_HOST`. Requests to the public cover hostname, unknown hostnames,
or arbitrary paths return a plain `404 Not Found`.

A one-host migration is supported by setting `RELAYQUAY_APP_HOST` equal to the
old `RELAYQUAY_PUBLIC_HOST` and retaining Access on that hostname. In active
mode that hostname serves the app rather than an anonymous cover. Prefer two
hostnames for new deployments.

## Environment

Set these values in the private env file:

```bash
RELAYQUAY_GATEWAY=app
RELAYQUAY_MODE=active
RELAYQUAY_PUBLIC_HOST=relayquay-public.example.com
RELAYQUAY_APP_HOST=relayquay-private.example.com
RELAYQUAY_APP_UPSTREAM=127.0.0.1:45080
CLOUDFLARE_TUNNEL_TOKEN="<your-cloudflare-tunnel-token>"
```

Run the private app separately and bind it to loopback. For example, if your
app listens on `127.0.0.1:45080`, RelayQuay will reverse proxy to that address.
The protected `/healthz` and `/.well-known/relayquay` paths are answered by
RelayQuay without reaching the app.

Older RustOpViewer configs may temporarily use `ROV_UPSTREAM`. RelayQuay maps
that compatibility variable to `RELAYQUAY_APP_UPSTREAM`; migrate the private
env after `doctor` reports it.

## Commands

Start the protected app gateway:

```bash
./bin/relayquay activate
```

Keep the tunnel online but serve only the neutral cover response:

```bash
./bin/relayquay cover
```

Configure cover mode and stop the Cloudflare connector:

```bash
./bin/relayquay pause
```

## Cloudflare Access

Create the Access application for `RELAYQUAY_APP_HOST`, not
`RELAYQUAY_PUBLIC_HOST`.

Recommended settings:

- Application domain: `relayquay-private.example.com`
- Policy action: `Allow`
- Include: your email address or identity group
- Session duration: short enough for your risk tolerance
- App Launcher visible: off

The public cover hostname should have only DNS and Tunnel routing. It should not
have a Cloudflare Access application, because Access redirects reveal that the
hostname is protected before the request can reach the cover response.
