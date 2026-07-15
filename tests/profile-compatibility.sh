#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

mkdir -p "$TMP_DIR/bin"
cat >"$TMP_DIR/bin/docker" <<'FAKE_DOCKER'
#!/usr/bin/env bash
set -euo pipefail
printf 'gateway=%s\n' "${RELAYQUAY_GATEWAY:-}"
printf 'mode=%s\n' "${RELAYQUAY_MODE:-}"
printf 'app_host=%s\n' "${RELAYQUAY_APP_HOST:-}"
printf 'app_upstream=%s\n' "${RELAYQUAY_APP_UPSTREAM:-}"
printf 'caddyfile=%s\n' "${RELAYQUAY_CADDYFILE:-}"
printf 'args='
printf ' %s' "$@"
printf '\n'
FAKE_DOCKER
chmod +x "$TMP_DIR/bin/docker"

run_config() {
  env -i \
    HOME="${HOME:-/tmp}" \
    PATH="$TMP_DIR/bin:$PATH" \
    USER="${USER:-relayquay}" \
    RELAYQUAY_ENV_FILE="$1" \
    "$ROOT_DIR/bin/relayquay" config
}

assert_contains() {
  local output="$1"
  local expected="$2"
  if [[ "$output" != *"$expected"* ]]; then
    printf 'expected output to contain %q\n%s\n' "$expected" "$output" >&2
    return 1
  fi
}

cat >"$TMP_DIR/legacy.env" <<'EOF_LEGACY'
RELAYQUAY_PUBLIC_HOST=rov.example.com
ROV_UPSTREAM=127.0.0.1:45123
EOF_LEGACY

legacy_output="$(run_config "$TMP_DIR/legacy.env")"
assert_contains "$legacy_output" "gateway=rustopviewer"
assert_contains "$legacy_output" "mode=cover"
assert_contains "$legacy_output" "app_upstream=127.0.0.1:45123"
assert_contains "$legacy_output" "caddyfile=./deploy/caddy/Caddyfile.cover"

cat >"$TMP_DIR/legacy-active.env" <<'EOF_LEGACY_ACTIVE'
RELAYQUAY_MODE=active
RELAYQUAY_PUBLIC_HOST=rov.example.com
ROV_UPSTREAM=127.0.0.1:45123
EOF_LEGACY_ACTIVE

if legacy_active_output="$(run_config "$TMP_DIR/legacy-active.env" 2>&1)"; then
  echo "expected an active legacy config without RELAYQUAY_APP_HOST to fail" >&2
  exit 1
fi
assert_contains "$legacy_active_output" "requires RELAYQUAY_APP_HOST"

cat >"$TMP_DIR/rustopviewer.env" <<'EOF_RUSTOPVIEWER'
RELAYQUAY_GATEWAY=rustopviewer
RELAYQUAY_MODE=active
RELAYQUAY_PUBLIC_HOST=relayquay-cover.example.com
RELAYQUAY_APP_HOST=rov.example.com
RELAYQUAY_APP_UPSTREAM=127.0.0.1:45080
EOF_RUSTOPVIEWER

rustopviewer_output="$(run_config "$TMP_DIR/rustopviewer.env")"
assert_contains "$rustopviewer_output" "gateway=rustopviewer"
assert_contains "$rustopviewer_output" "mode=active"
assert_contains "$rustopviewer_output" "app_host=rov.example.com"
assert_contains "$rustopviewer_output" "caddyfile=./deploy/caddy/Caddyfile.app"

cat >"$TMP_DIR/rustdesk.env" <<'EOF_RUSTDESK'
RELAYQUAY_GATEWAY=rustdesk
RELAYQUAY_MODE=active
RELAYQUAY_WEBCLIENT=1
RELAYQUAY_WEBCLIENT_PATH=/sky
EOF_RUSTDESK

rustdesk_output="$(run_config "$TMP_DIR/rustdesk.env")"
assert_contains "$rustdesk_output" "gateway=rustdesk"
assert_contains "$rustdesk_output" "caddyfile=./deploy/caddy/Caddyfile"
assert_contains "$rustdesk_output" "webclient.yaml"

echo "profile compatibility checks passed"
