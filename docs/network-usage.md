# Network Usage

RelayQuay is designed to stay quiet while idle. The always-on cost is mostly
Cloudflare Tunnel keepalive traffic plus occasional DNS/TLS control traffic.

The expensive part is an active RustDesk remote desktop session. Screen
resolution, frame rate, image quality, video motion, audio, clipboard, and file
transfer settings dominate bandwidth. RelayQuay cannot compress or reshape the
encrypted RustDesk desktop stream after the browser and server create it.

## Defaults That Reduce Waste

- Cloudflare Access rejects unauthenticated users at Cloudflare's edge before
  they can consume tunnel or origin bandwidth.
- `cloudflared` runs with `--no-autoupdate`, avoiding surprise update downloads.
- The default `cloudflared` tag is pinned instead of `latest`.
- Caddy only serves the health endpoint, WebSocket routes, and optional static
  files you explicitly mount.
- The RustDesk server containers are behind an opt-in Compose profile.

## Metered Links

For metered Wi-Fi or mobile links:

- Stop RelayQuay when you do not need browser access:

  ```bash
  ./bin/relayquay stop cloudflared
  ```

- Start the tunnel again when needed:

  ```bash
  ./bin/relayquay up cloudflared
  ```

- Keep native RustDesk clients on LAN, Tailscale, or WireGuard when possible.
- Lower quality, resolution, and frame rate in the RustDesk client during long
  sessions.
- Avoid file transfer and audio over metered links unless needed.
- Keep Cloudflare Access enabled so anonymous traffic is blocked at the edge.

## Configuration

These optional env values are useful on constrained networks:

```bash
CLOUDFLARED_PROTOCOL=quic
RELAYQUAY_RESTART_POLICY=unless-stopped
```

Use `RELAYQUAY_RESTART_POLICY=no` if you want Docker to leave the tunnel down
after you stop it manually.
