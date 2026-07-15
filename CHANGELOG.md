# Changelog

All notable changes to RelayQuay are recorded here.

## Unreleased

- Restored RustOpViewer as a first-class, fail-closed profile with legacy env
  migration, protected health checks, loopback exposure diagnostics, and
  dedicated security and operations guidance.
- Replaced the unsafe vendored Plugroot integration with a standalone checkout
  registration example.
- Added generic private HTTP app mode for loopback services such as
  RustOpViewer.
- Added transport-profile docs for Cloudflare, onion service, and VPS tunnel
  modes.
- Added a v3 onion service guide and torrc example.
- Added cover, pause, and activate helper commands with a neutral `404 Not
  Found` cover response.
- Added Cloudflare Terraform support for a public cover hostname plus an
  optional separate Access-protected app hostname.
- Added a configurable optional web-client path.
- Added optional private static web-client hosting.
- Added formal project docs and metered-network guidance.
- Added infrastructure, operations, ADR, and Terraform reference docs.
- Moved runtime deployment files under `deploy/`.
- Hardened public ignore rules and genericized Plugroot integration examples.
- Added root-hosted web-client mode for dedicated protected hostnames.
- Fixed containerized `cloudflared` loopback origin routing.
