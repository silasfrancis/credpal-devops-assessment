resource "cloudflare_dns_record" "validation" {
  for_each = {
    for dvo in var.domain_validation_options : dvo.domain_name => {
      name    = dvo.resource_record_name
      content = dvo.resource_record_value
      type    = dvo.resource_record_type
    }
  }

  zone_id = var.zone_id
  name    = each.value.name
  content = each.value.content 
  type    = each.value.type
  ttl     = 60
  proxied = false 
}