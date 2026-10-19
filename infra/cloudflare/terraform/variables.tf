variable "cloudflare_account_id" {
  description = "Cloudflare account ID."
  type        = string
  sensitive   = true
}

variable "cloudflare_zone_id" {
  description = "Cloudflare zone ID for the public hostname."
  type        = string
  sensitive   = true
}

variable "tunnel_id" {
  description = "Existing Cloudflare Tunnel ID."
  type        = string
  sensitive   = true
}

variable "public_hostname" {
  description = "Public hostname routed to RelayQuay. In rustdesk mode this is the Access-protected hostname; in app and cover modes it is the cover hostname and must not carry Cloudflare Access."
  type        = string
}

variable "gateway_mode" {
  description = "RelayQuay gateway mode this tunnel serves (RELAYQUAY_GATEWAY/RELAYQUAY_MODE): rustdesk requires access_application_domain = public_hostname; app needs a separate access_application_domain; cover leaves it empty."
  type        = string
  default     = "rustdesk"

  validation {
    condition     = contains(["rustdesk", "app", "cover"], var.gateway_mode)
    error_message = "gateway_mode must be rustdesk, app, or cover."
  }
}

variable "origin_service" {
  description = "Origin service configured in the tunnel ingress."
  type        = string
  default     = "http://127.0.0.1:8788"
}

variable "access_application_domain" {
  description = "Cloudflare Access application domain. rustdesk mode: must equal public_hostname. app mode: a separate protected hostname. cover mode: leave empty."
  type        = string
  default     = ""
}

variable "create_access_dns_record" {
  description = "Create a proxied DNS record for access_application_domain."
  type        = bool
  default     = true
}

variable "access_application_name" {
  description = "Cloudflare Access application name."
  type        = string
  default     = "RelayQuay"
}

variable "access_session_duration" {
  description = "Cloudflare Access session duration."
  type        = string
  default     = "24h"
}

variable "allowed_emails" {
  description = "Email identities allowed by the Access policy when access_application_domain is set."
  type        = list(string)
  default     = []
}
