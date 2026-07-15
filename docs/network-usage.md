# Network Usage

RelayQuay is designed to stay quiet while idle. The always-on cost is mostly
Cloudflare Tunnel keepalive traffic plus occasional DNS/TLS control traffic.

The expensive part is an active remote desktop session. Screen resolution,
stream profile, frame rate, image quality, video motion, audio, clipboard, and
file transfer settings dominate bandwidth. RelayQuay does not compress or
reshape the application stream.

## Defaults That Reduce Waste

- Cloudflare Access rejects unauthenticated users at Cloudflare's edge before
  they can consume tunnel or origin bandwidth.
- `cloudflared` runs with `--no-autoupdate`, avoiding surprise update downloads.
- The default `cloudflared` tag is pinned instead of `latest`.
- Caddy only serves the health endpoint, WebSocket routes, and optional static
  files you explicitly mount.
- RustOpViewer provides Balanced, Data Saver, and Emergency stream profiles.
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
- Use RustOpViewer's Data Saver or Emergency profile during long or unstable
  metered sessions.
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
