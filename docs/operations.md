# Operations

## Start

```bash
./bin/relayquay doctor
./bin/relayquay up
./bin/relayquay status
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

Unauthenticated requests should redirect to Cloudflare Access:

```bash
curl -I https://rustdesk-wss.example.com/healthz
```

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
