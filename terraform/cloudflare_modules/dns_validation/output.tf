output "validation_fqdns" {
  value = [for record in cloudflare_dns_record.validation : record.name]
}