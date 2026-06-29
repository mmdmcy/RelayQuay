output "public_hostname" {
  value = var.public_hostname
}

output "dns_record_id" {
  value = cloudflare_record.relayquay.id
}

output "access_application_id" {
  value = cloudflare_access_application.relayquay.id
}
