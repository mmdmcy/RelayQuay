# Repository Layout

```text
.
├── bin/                    Helper CLI
├── docs/                   Architecture, operations, and security docs
├── docs/adr/               Architecture decision records
├── examples/               Firewall and host integration examples
├── infra/                  Reference infrastructure-as-code
├── Caddyfile               Default WSS gateway
├── Caddyfile.webclient     Optional static web-client gateway
├── compose.yaml            Core services
└── compose.webclient.yaml  Optional web-client overlay
```

## Public Source

Public source should stay generic and reusable.

Commit:

- helper scripts
- Compose files
- Caddyfiles
- sanitized examples
- architecture and operations docs
- reference infrastructure templates

Do not commit:

- real `.env` files
- `.tfvars`
- Terraform state
- tunnel tokens
- real private deployment hostnames
- RustDesk private keys or databases
- generated static web-client assets
- local operator notes
