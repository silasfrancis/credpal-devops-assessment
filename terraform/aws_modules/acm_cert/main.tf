data "aws_acm_certificate" "lefrancis_org" {
    domain = "lefrancis.org"
    statuses = ["ISSUED"]
}