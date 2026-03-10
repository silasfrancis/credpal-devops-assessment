output "certificate_arn" {
  value = data.aws_acm_certificate.cert.arn
}

output "domain_validation_options" {
  value = data.aws_acm_certificate.cert.domain_validation_options
}