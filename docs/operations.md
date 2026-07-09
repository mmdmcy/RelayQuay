# Operations

## Start

```bash
./bin/relayquay doctor
./bin/relayquay activate
./bin/relayquay status
```

## Cover and Pause

Serve only the neutral cover response while keeping Cloudflare Tunnel online:

```bash
./bin/relayquay cover
```

Configure cover mode and stop only the Cloudflare connector:

```bash
./bin/relayquay pause
```

## Stop Metered Tunnel Traffic

Stop only the Cloudflare connector while keeping local configuration intact:

```bash
./bin/relayquay stop cloudflared
```

Start it again:

```bash
./bin/relayquay up cloudflared
```

## Verify Public Access

For RustDesk WSS mode, unauthenticated requests to the protected WSS hostname
should redirect to Cloudflare Access:

```bash
curl -I https://rustdesk-wss.example.com/healthz
```

For private app mode, the public cover hostname should not redirect to
Cloudflare Access:

```bash
curl -i https://relayquay-public.example.com/
```

Expected shape:

```text
HTTP/2 404
content-type: text/plain; charset=utf-8

Not Found
```

The protected app hostname should be the only hostname that redirects to
Cloudflare Access before login:

```bash
curl -I https://relayquay-private.example.com/
```

For onion service mode, the generated onion hostname should only be shared with
authorized users, and private services should use onion client authorization.
After Tor starts, check the hostname with:

```bash
sudo cat /var/lib/tor/relayquay/hostname
```

Then set `RELAYQUAY_APP_HOST` to that full `.onion` hostname and run:

```bash
./bin/relayquay activate
```

If Cloudflare returns `502 Bad Gateway` after Access login, check that the
tunnel ingress uses `http://127.0.0.1:8788` and that the `cloudflared` container
is running with host networking.

The local gateway should respond directly on loopback:

```bash
curl -fsS http://127.0.0.1:8788/healthz
```

## Rotate Tunnel Token

1. Create or rotate the tunnel token in Cloudflare.
2. Update only the private env file selected by `RELAYQUAY_ENV_FILE`.
3. Restart `cloudflared`:

   ```bash
   ./bin/relayquay up cloudflared
   ```

## Firewall Review

Confirm raw RustDesk ports are not publicly allowed:

```bash
sudo ufw status numbered
```

Expected shape:

- trusted private interface/network allow rules first
- public deny rules for `21115:21119/tcp`
- public deny rules for `21115:21119/udp`
