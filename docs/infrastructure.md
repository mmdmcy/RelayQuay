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
- `cloudflared` as an outbound connector.
- An existing RustDesk server, or the optional RustDesk server Compose profile.
- A host firewall that allows raw RustDesk ports only from trusted private
  networks.

## Cloudflare

The Cloudflare side has these resources:

- DNS record for the protected RelayQuay hostname.
- Cloudflare Tunnel public hostname pointing to `http://localhost:8788`.
- Cloudflare Access self-hosted application for the protected hostname.
- Cloudflare Access allow policy for trusted identities.
- Optional redirect rule from a friendly website path to the protected hostname.

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
