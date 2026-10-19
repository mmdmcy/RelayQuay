resource "cloudflare_record" "relayquay" {
  zone_id = var.cloudflare_zone_id
  name    = var.public_hostname
  type    = "CNAME"
  content = "${var.tunnel_id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

locals {
  access_enabled = var.access_application_domain != ""
  # Access on the public hostname itself (rustdesk mode): reuse its DNS record
  # and ingress instead of creating duplicates.
  access_on_public_hostname = local.access_enabled && var.access_application_domain == var.public_hostname
  separate_access_hostname  = local.access_enabled && !local.access_on_public_hostname
}

resource "cloudflare_record" "relayquay_access" {
  count = local.separate_access_hostname && var.create_access_dns_record ? 1 : 0

  zone_id = var.cloudflare_zone_id
  name    = var.access_application_domain
  type    = "CNAME"
  content = "${var.tunnel_id}.cfargotunnel.com"
  proxied = true
  ttl     = 1
}

resource "cloudflare_tunnel_config" "relayquay" {
  account_id = var.cloudflare_account_id
  tunnel_id  = var.tunnel_id

  config {
    ingress_rule {
      hostname = var.public_hostname
      service  = var.origin_service
    }

    dynamic "ingress_rule" {
      for_each = local.separate_access_hostname ? [var.access_application_domain] : []

      content {
        hostname = ingress_rule.value
        service  = var.origin_service
      }
    }

    ingress_rule {
      service = "http_status:404"
    }
  }

  lifecycle {
    # Every hostname that reaches the origin must match what the Caddyfile
    # protects. In rustdesk mode the origin serves the RustDesk endpoints to
    # public_hostname, so Access must sit on that exact hostname; in app and
    # cover modes public_hostname is the cover and must stay Access-free.
    precondition {
      condition     = var.gateway_mode != "rustdesk" || local.access_on_public_hostname
      error_message = "gateway_mode = rustdesk requires access_application_domain to equal public_hostname, otherwise the RustDesk WebSocket endpoints are reachable without Cloudflare Access."
    }
    precondition {
      condition     = var.gateway_mode != "app" || local.separate_access_hostname
      error_message = "gateway_mode = app requires access_application_domain to be a separate protected hostname, not empty and not public_hostname (the cover)."
    }
    precondition {
      condition     = var.gateway_mode != "cover" || !local.access_enabled
      error_message = "gateway_mode = cover must leave access_application_domain empty; Access on the cover hostname exposes the login redirect."
    }
  }
}

resource "cloudflare_access_application" "relayquay" {
  count = local.access_enabled ? 1 : 0

  account_id           = var.cloudflare_account_id
  name                 = var.access_application_name
  domain               = var.access_application_domain
  type                 = "self_hosted"
  session_duration     = var.access_session_duration
  app_launcher_visible = false
}

resource "cloudflare_access_policy" "allow_users" {
  count = local.access_enabled ? 1 : 0

  account_id     = var.cloudflare_account_id
  application_id = cloudflare_access_application.relayquay[0].id
  name           = "Allow RelayQuay users"
  precedence     = 1
  decision       = "allow"

  include {
    email = var.allowed_emails
  }
}
