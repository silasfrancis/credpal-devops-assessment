resource "aws_lb" "app_lb" {
  name = "${var.tags}-alb"
  load_balancer_type = "application"
  internal = false
  subnets = var.public_subnets
  security_groups = var.security_groups
}