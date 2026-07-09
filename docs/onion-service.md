# Onion Service Transport

Onion service mode is an advanced transport for reaching RelayQuay without
Cloudflare, public DNS, router port forwarding, Tailscale, or WireGuard. It
uses Tor to publish a v3 onion service that forwards to RelayQuay's loopback
Caddy gateway.

This mode is appropriate for private HTTP/WebSocket app mode, including tools
such as RustOpViewer that are run separately from RelayQuay. It is usually not
ideal for high-frame-rate remote desktop because Tor adds latency.

## Shape

```text
Tor Browser or Tor client
  -> v3 onion service
  -> local Tor daemon
  -> http://127.0.0.1:8788
  -> RelayQuay Caddy gateway
  -> private loopback app
```

## Required Controls

Use these controls together:

- v3 onion service only.
- Onion client authorization for private services.
- Caddy bound to loopback.
- `RELAYQUAY_GATEWAY=app`.
- `RELAYQUAY_APP_HOST` set to the generated onion hostname.
- The private app bound to loopback.
- A separate app login or approval flow where the app supports one.

An onion address is not a password. If client authorization is not configured,
anyone who learns the onion address can attempt to connect.

## RelayQuay Environment

Set the private env file for app mode:

```bash
RELAYQUAY_GATEWAY=app
RELAYQUAY_MODE=active
RELAYQUAY_APP_UPSTREAM=127.0.0.1:45080
```

After Tor creates the onion service, read its hostname:

```bash
sudo cat /var/lib/tor/relayquay/hostname
```

Then set:

```bash
RELAYQUAY_APP_HOST=<generated-onion-hostname>.onion
```

Start RelayQuay:

```bash
./bin/relayquay activate
```

## Tor Service Configuration

Use the example torrc fragment in
[examples/tor/torrc.relayquay-onion](../examples/tor/torrc.relayquay-onion).

The important mapping is:

```text
HiddenServicePort 80 127.0.0.1:8788
```

That means Tor exposes virtual onion port `80` and forwards it only to
RelayQuay's loopback Caddy listener.

## Client Authorization

Tor v3 onion client authorization uses a client key pair. The service stores
the client's public key under:

```text
<HiddenServiceDir>/authorized_clients/
```

Each authorized client file must end in `.auth` and contain:

```text
descriptor:x25519:<base32-encoded-public-key>
```

The client stores or imports the matching private key. On a system Tor client,
the client-side file uses the `.auth_private` suffix and contains:

```text
<56-char-onion-address-without-.onion>:descriptor:x25519:<base32-encoded-private-key>
```

Tor Browser can also import the private key through its onion service
authentication UI.

Restart or reload Tor after adding or removing authorization files. Revocation
does not take effect until Tor reloads the service configuration.

## Operational Notes

Do not publish onion hostnames, client authorization private keys, service
private keys, or generated `hostname` files in this repository.

For unattended remote-access tools, treat onion mode as transport privacy, not
complete application security. Keep app authentication enabled and review local
logs.
