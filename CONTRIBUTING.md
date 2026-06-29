# Contributing

RelayQuay is public-source infrastructure code. Treat every contribution as if
it will be published.

## Development

Run the lightweight checks before opening a pull request:

```bash
bash -n bin/relayquay
RELAYQUAY_ENV_FILE=.env.example ./bin/relayquay config >/tmp/relayquay-compose.yaml
```

For web-client overlay changes:

```bash
tmpenv=$(mktemp)
cp .env.example "$tmpenv"
sed -i 's/^RELAYQUAY_WEBCLIENT=.*/RELAYQUAY_WEBCLIENT=1/' "$tmpenv"
RELAYQUAY_ENV_FILE="$tmpenv" ./bin/relayquay config >/tmp/relayquay-webclient-compose.yaml
rm -f "$tmpenv"
```

## Privacy

Do not commit real `.env` files, tunnel tokens, hostnames for private
deployments, RustDesk private keys, logs, databases, screenshots, or local
operator notes.

Use placeholders in examples and keep real values in the private env file
selected by `RELAYQUAY_ENV_FILE`.
