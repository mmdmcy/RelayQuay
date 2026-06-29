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
  description = "Access-protected hostname used by RelayQuay."
  type        = string
}

variable "origin_service" {
  description = "Origin service configured in the tunnel ingress."
  type        = string
  default     = "http://localhost:8788"
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
  description = "Email identities allowed by the Access policy."
  type        = list(string)
}
