{
	auto_https off
	admin off
}

http://:{$RELAYQUAY_LISTEN_PORT:8788} {
	bind {$RELAYQUAY_BIND:127.0.0.1}

	header {
		X-Content-Type-Options nosniff
		Referrer-Policy no-referrer
		Permissions-Policy "camera=(), microphone=(), geolocation=(), payment=()"
	}

	@localHealth {
		host 127.0.0.1 localhost
		path /healthz /.well-known/relayquay
	}
	handle @localHealth {
		respond "relayquay ok" 200
	}

	@appHost host {$RELAYQUAY_APP_HOST:relayquay-app.invalid}
	handle @appHost {
		@appHealth path /healthz /.well-known/relayquay
		respond @appHealth "relayquay ok" 200

		reverse_proxy {$RELAYQUAY_APP_UPSTREAM:127.0.0.1:45080} {
			header_up Host {host}
			header_up X-Real-IP {remote_host}
			header_up X-Forwarded-Proto https
		}
	}

	handle {
		header {
			Cache-Control "no-store"
			Content-Security-Policy "default-src 'none'; style-src 'unsafe-inline'; img-src 'self' data:; base-uri 'none'; form-action 'none'; frame-ancestors 'none'"
			Content-Type "text/plain; charset=utf-8"
			X-Robots-Tag "noindex, nofollow, noarchive"
		}

		respond "Not Found" 404
	}
}
