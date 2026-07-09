# Security

RelayQuay is designed to be public source code with private runtime state.

## Do Not Commit

- Cloudflare Tunnel tokens.
- Real hostnames or domains for private deployments.
- Generated onion hostnames, onion service keys, or onion client authorization
  keys.
- RustDesk private keys or server databases.
- Real `.env` files.
- Local firewall state, service logs, media, backups, or machine notes.
- Web-client build output that contains private hostnames or deployment-specific
  settings.

Use `.env.example` and `example.com` style values in public files. Keep real
values in a private env file selected with `RELAYQUAY_ENV_FILE`.

## Expected Exposure

The intended public surface depends on the selected transport: a
Cloudflare-protected hostname, an authenticated onion service, or an
operator-owned VPS edge. The raw RustDesk ports should stay private to
loopback, LAN, VPN, or an explicit firewall allowlist.

## Reporting

Open an issue with a minimal reproduction and avoid including secrets, real
hostnames, or private network details.
