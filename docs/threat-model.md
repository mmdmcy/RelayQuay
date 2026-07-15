# Threat Model

RelayQuay is for personal remote-access workflows from browsers and devices
that are not on your private VPN.

## Goals

- Let `https://rustdesk.com/web` reach your self-hosted RustDesk server through
  WebSocket Secure.
- Let RustOpViewer or another private loopback HTTP/WebSocket app be reached
  through a separate Access-protected hostname.
- Require identity authentication before any browser can reach the WSS gateway.
- Keep public cover hostnames from exposing Cloudflare Access login redirects.
- Avoid public exposure of RustDesk's raw TCP/UDP ports.
- Keep real operational state under `/var/lib/relayquay`, outside Git.

## Non-Goals

- RelayQuay is not a RustDesk account system.
- RelayQuay is not a replacement for RustDesk device passwords, approvals, or
  key verification.
- RelayQuay and Cloudflare Access do not replace RustOpViewer pairing, session,
  remembered-browser, view-only, revocation, or panic-stop controls.
- RelayQuay does not make an untrusted browser or unmanaged device trusted.
- RelayQuay does not hide traffic metadata from Cloudflare.
- Onion service mode does not make app authentication optional.

## Main Risks

### Public RustDesk Ports

Opening `21115-21119/tcp` or `21116/udp` to the Internet increases the attack
surface. RelayQuay's default path publishes only an HTTPS hostname with Access
in front.

### Public App Ports

Binding RelayQuay or RustOpViewer to a wildcard interface bypasses the intended
tunnel boundary. Keep `8788` and the configured app port, normally `45080`, on
loopback. If trusted LAN or VPN access is deliberate, add reviewed allow rules
before denying all other inbound traffic to those ports.

### Access Redirect Disclosure

Cloudflare Access redirects are visible to anonymous users. For private app
mode, do not attach Access to the public cover hostname. Route the public
hostname to RelayQuay's cover response, and attach Access only to the separate
protected app hostname.

### Onion Address Disclosure

An onion address is not a password. Onion service mode should use v3 onion
client authorization for private remote-access services. If client
authorization is not configured, anyone who learns the onion address can try to
connect.

### Third-Party Edge Trust

Cloudflare mode uses Cloudflare as the public edge. VPS mode uses an
operator-owned edge. Onion mode avoids a centralized edge but requires Tor
client software and adds latency.

### Access Cookie Requirement

The RustDesk Web client runs on `rustdesk.com`, while the WSS endpoints live on
your hostname. Authenticate to your hostname first, for example by opening
`https://rustdesk-wss.example.com/healthz`, so the browser has a valid
Cloudflare Access session before the web client opens WebSockets.

### Relay Address Mismatch

If `hbbs` advertises a relay address that is only reachable on Tailscale or LAN,
the public browser can reach signaling and still fail during relay setup. The
relay address used by the browser must be reachable through the public WSS
hostname.

### Shared or Untrusted Devices

Cloudflare Access proves the browser user authenticated. It does not prove the
device is safe. Use short Access session durations on shared machines and avoid
saving RustDesk secrets in the browser.

For RustOpViewer, Access authentication still leaves the app's own approval
boundary in place. Use short-lived sessions, enable remembered trust only on a
controlled browser, revoke lost browsers, and use view-only or panic stop when
remote input should be disabled.

## Recommended Controls

- Cloudflare Access allow policy for your identity only.
- MFA on the identity provider.
- Short Access session duration for this application.
- RustOpViewer host-approved pairing and regular remembered-browser review.
- RustOpViewer view-only mode or panic stop when control should be disabled.
- Separate public cover and protected app hostnames when using generic app
  mode.
- v3 onion client authorization when using onion service mode.
- RustDesk permanent password disabled unless you actually need it.
- Manual approval or a strong one-time password flow on controlled devices.
- Host firewall denying public access to `8788`, the app upstream port, and
  `21115-21119`.
- Regular review of Cloudflare Access logs and local RustDesk logs.
