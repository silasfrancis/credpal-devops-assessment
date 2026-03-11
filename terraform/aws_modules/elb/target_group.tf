resource "aws_lb_target_group" "blue_target_group" {
  name     = "${var.tags}-blue-target"
  port     = 3000
  protocol = "HTTP"
  vpc_id  = var.vpc_id

  health_check {
    path = "/"
    matcher = "200"
  }
}


resource "aws_lb_target_group" "green_target_group" {
  name     = "${var.tags}-green-target"
  port     = 3001
  protocol = "HTTP"
  vpc_id  = var.vpc_id

  health_check {
    path = "/"
    matcher = "200"
  }
}
