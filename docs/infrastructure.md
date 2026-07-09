# Infrastructure

RelayQuay separates public source, private runtime state, and provider-managed
infrastructure.

## Source

The repository contains reusable code, examples, documentation, and reference
infrastructure templates. It must not contain real hostnames, tunnel tokens,
Cloudflare credentials, RustDesk private keys, logs, databases, or local notes.

## Runtime Host

The host runs:

- Docker Engine and Docker Compose.
- Caddy bound to loopback for the local gateway.
- An optional transport connector such as `cloudflared`, Tor, or a VPS tunnel.
- An existing RustDesk server, the optional RustDesk server Compose profile, or
  a separate loopback HTTP/WebSocket app.
- A host firewall that allows raw RustDesk ports only from trusted private
  networks.

## Cloudflare

The Cloudflare side, when used, has these resources:

- DNS record for the public RelayQuay cover hostname.
- Cloudflare Tunnel public hostname pointing to `http://localhost:8788`.
- Optional DNS record for a separate protected app hostname.
- Optional Cloudflare Access self-hosted application for the protected hostname.
- Optional Cloudflare Access allow policy for trusted identities.
- Optional redirect rule from a friendly website path to the protected hostname.

## Onion Service

The Tor side, when used, has:

- A v3 onion service.
- `HiddenServicePort 80 127.0.0.1:8788`.
- Optional but strongly recommended client authorization files under
  `<HiddenServiceDir>/authorized_clients/`.

## State Boundaries

Private runtime files belong under the operator's selected state root, normally
`/var/lib/relayquay`.

Terraform state, `.tfvars`, Cloudflare tokens, and generated web-client assets
are private operational state and are ignored by Git.

## Reference IaC

The Terraform reference in
[infra/cloudflare/terraform](../infra/cloudflare/terraform) manages the generic
Cloudflare resources for an existing tunnel ID. Import existing resources before
using it against a live zone that already has equivalent manual resources.
