# RelayQuay Cloudflare Terraform Reference

This directory is a reference implementation for managing the generic
Cloudflare side of RelayQuay.

It manages:

- DNS record for the public RelayQuay hostname.
- Tunnel public-hostname ingress for an existing tunnel ID.
- Optional DNS and tunnel ingress for a separate protected app hostname.
- Optional Cloudflare Access self-hosted application on that separate domain.
- Optional Cloudflare Access allow policy.

It intentionally does not store tunnel tokens, API tokens, or Terraform state in
Git.

## Usage

Copy the example variables file and fill it with private values:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Then run:

```bash
terraform init
terraform plan
terraform apply
```

If you already created resources manually, import them before applying. Applying
without imports can create duplicates or overwrite provider-managed settings.

Set `gateway_mode` to the mode RelayQuay runs in; `terraform plan` fails when
the hostnames do not fit that mode:

- `rustdesk` (default): set `access_application_domain = public_hostname`. The
  tunnel routes that one hostname to the origin and Access protects it, which
  is what the rustdesk Caddyfile expects (it only serves requests for
  `RELAYQUAY_PUBLIC_HOST` that carry the `Cf-Access-Jwt-Assertion` header).
- `app`: set `access_application_domain` to the same hostname as
  `RELAYQUAY_APP_HOST` and keep `public_hostname` as the cover hostname.
- `cover`: leave `access_application_domain` empty.

Do not point a Cloudflare Access application at a public cover hostname,
because anonymous requests to `/` will reveal the Cloudflare Access login
endpoint before the request can reach the cover response.

## Required Cloudflare Permissions

Use a scoped token where possible:

- Account: Cloudflare Tunnel Edit
- Account: Access: Apps and Policies Edit
- Zone: DNS Edit

The redirect from an existing website path is intentionally not managed here.
Use Cloudflare Redirect Rules, Pages, or Workers for that edge-routing layer
after reviewing any existing zone rules.
