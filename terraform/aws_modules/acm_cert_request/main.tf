resource "aws_acm_certificate" "cert" {
  domain_name               = "lefrancis.org"
  subject_alternative_names = ["*.lefrancis.org"]
  validation_method         = "DNS"

  lifecycle {
   create_before_destroy = true
  }
}