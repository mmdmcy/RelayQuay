# Security

RelayQuay is designed to be public source code with private runtime state.

## Do Not Commit

- Cloudflare Tunnel tokens.
- Real hostnames or domains for private deployments.
- RustDesk private keys or server databases.
- Real `.env` files.
- Local firewall state, service logs, media, backups, or machine notes.

Use `.env.example` and `rustdesk-wss.example.com` style placeholders in public
files. Keep real values in `/var/lib/relayquay/relayquay.env`, or another
private file selected with `RELAYQUAY_ENV_FILE`.

## Expected Exposure

The only intended public surface is an HTTPS hostname protected by Cloudflare
Access. The raw RustDesk ports should stay private to loopback, LAN, VPN, or an
explicit firewall allowlist.

## Reporting

Open an issue with a minimal reproduction and avoid including secrets, real
hostnames, or private network details.
