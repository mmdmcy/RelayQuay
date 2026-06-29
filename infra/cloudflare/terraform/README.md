# RelayQuay Cloudflare Terraform Reference

This directory is a reference implementation for managing the generic
Cloudflare side of RelayQuay.

It manages:

- DNS record for the protected RelayQuay hostname.
- Tunnel public-hostname ingress for an existing tunnel ID.
- Cloudflare Access self-hosted application.
- Cloudflare Access allow policy.

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

## Required Cloudflare Permissions

Use a scoped token where possible:

- Account: Cloudflare Tunnel Edit
- Account: Access: Apps and Policies Edit
- Zone: DNS Edit

The redirect from an existing website path is intentionally not managed here.
Use Cloudflare Redirect Rules, Pages, or Workers for that edge-routing layer
after reviewing any existing zone rules.
