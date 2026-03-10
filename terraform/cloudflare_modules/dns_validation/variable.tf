variable "domain_validation_options" {
  type = list(object({
    domain_name              = string
    resource_record_name    = string
    resource_record_value   = string
    resource_record_type    = string
  }))
}

variable "zone_id" {
  type = string
}