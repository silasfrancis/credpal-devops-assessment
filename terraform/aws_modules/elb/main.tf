resource "aws_lb" "app_lb" {
  name = "${var.tags}-alb"
  load_balancer_type = "application"
  internal = false
  subnets = var.public_subnets
  security_groups = var.security_groups
  drop_invalid_header_fields = true
  enable_deletion_protection = true

  access_logs {
    bucket  = var.alb_log_bucket_id
    prefix  = var.alb_log_bucket_prefix
    enabled = true
  }
}