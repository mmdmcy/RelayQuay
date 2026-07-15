# Firewall

RelayQuay does not automatically change the host firewall. Firewall policy is
host-specific and a bad rule can lock you out or break private clients.

The intended policy is:

- Allow outbound `cloudflared` traffic to Cloudflare.
- Allow loopback access to the Caddy gateway on `127.0.0.1:8788`.
- Keep RustOpViewer/private app upstreams on loopback, normally
  `127.0.0.1:45080`.
- Deny non-loopback access to `8788` and the configured app port unless a
  reviewed LAN or VPN exception is intentional.
- Allow RustDesk raw ports only from private networks you trust.
- Deny public access to `21115-21119/tcp` and `21115-21119/udp`.

## RustDesk Ports

```text
21115/tcp       NAT type test
21116/tcp+udp   rendezvous, heartbeat, and TCP hole punching
21117/tcp       relay
21118/tcp       hbbs WebSocket
21119/tcp       hbbr WebSocket
```

## UFW Sketch

Adjust the source networks before applying:

```bash
# Add these only when the app intentionally listens beyond loopback.
sudo ufw allow in on tailscale0 to any port 8788 proto tcp
sudo ufw allow in on tailscale0 to any port 45080 proto tcp

sudo ufw allow in on tailscale0 to any port 21115:21119 proto tcp
sudo ufw allow in on tailscale0 to any port 21116 proto udp
sudo ufw allow from 192.168.0.0/16 to any port 21115:21119 proto tcp
sudo ufw allow from 192.168.0.0/16 to any port 21116 proto udp

sudo ufw deny 8788/tcp
sudo ufw deny 45080/tcp
sudo ufw deny 21115:21119/tcp
sudo ufw deny 21115:21119/udp
```

UFW normally permits loopback separately. Confirm that assumption against the
host's actual rules before applying this sketch. Replace `45080` when
`RELAYQUAY_APP_UPSTREAM` uses a different port, and place deliberate allow
rules before the matching deny rules.

## nftables Example

See [examples/nftables/relayquay.nft](../examples/nftables/relayquay.nft).

Review it before use. It is intentionally an example, not an installer.
