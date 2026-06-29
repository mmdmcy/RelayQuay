# Optional Web Client Hosting

RelayQuay can optionally serve a self-hosted RustDesk web client on the same
Cloudflare Access protected hostname that exposes the WebSocket gateway.

This feature is disabled by default. RelayQuay does not ship, download, scrape,
or vendor RustDesk's hosted web application. Provide trusted static web assets
yourself, and make sure their license and update source are acceptable for your
deployment.

## Enable

Set these values in the private env file:

```bash
RELAYQUAY_WEBCLIENT=1
RUSTDESK_WEB_ROOT=/var/lib/relayquay/webclient
```

Place the static web client files in `RUSTDESK_WEB_ROOT`. At minimum,
`index.html` must exist:

```bash
sudo install -d -m 755 /var/lib/relayquay/webclient
sudo cp -a <trusted-web-build>/. /var/lib/relayquay/webclient/
```

Then validate and start RelayQuay:

```bash
./bin/relayquay doctor
./bin/relayquay up
```

## Routes

With `RELAYQUAY_WEBCLIENT=1`, Caddy uses the web-client overlay:

- `/` serves the supplied static web client.
- `/healthz` and `/.well-known/relayquay` return the RelayQuay health response.
- `/ws/id` proxies to `hbbs` WebSocket.
- `/ws/relay` proxies to `hbbr` WebSocket.

Cloudflare Tunnel should still route the public hostname to the local RelayQuay
listener, normally `http://127.0.0.1:8788`.

## Security Notes

- Keep Cloudflare Access enabled for the hostname.
- Do not commit web-client build output if it contains private hostnames,
  deployment-specific settings, or generated credentials.
- Update the supplied web assets from a source you trust.
- Keep raw RustDesk ports private unless you deliberately expose them with a
  firewall policy.
