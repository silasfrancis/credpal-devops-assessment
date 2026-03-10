terraform {
#     backend "s3" {
#     bucket = "silas-dns-silas-dns"
#     key = "dns/terraform.tfstate"
#     region = "us-east-2"
#     use_lockfile = true
#     encrypt = true
    
#   }

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "6.35.1"
    }

    cloudflare = {
      source = "cloudflare/cloudflare"
      version = "5.19.0-beta.1"
    }
  }
}

provider "aws" {
  region = "us-east-2"
}

provider "cloudflare" {
}

locals {
  environment = "dns"
  tag = "silas-dns"
}


module "acm_cert_request" {
    source = "../../aws_modules/acm_cert_request"
}

module "dns_validation" {
  source = "../../cloudflare_modules/dns_validation"

  zone_id = var.cloudflare_zone_id
  domain_validation_options = module.acm_cert_request.domain_validation_options
}

module "acm_cert_validation" {
  source = "../../aws_modules/acm_cert_validation"

  certificate_arn = module.acm_cert_request.certificate_arn
  validation_records = [module.dns_validation.validation_record_fqdns]
}

module "s3_tf_state" {
  source = "../../aws_modules/s3_tf_state"
  
  bucket_name = "${local.tag}-silas-${local.environment}"
  bucket_key = "${local.environment}/terraform.tfstate"
  bucket_tag_name = "${local.tag}"
  bucket_rule_id = "${local.tag}${local.environment}"
  bucket_exp_days = 60
}