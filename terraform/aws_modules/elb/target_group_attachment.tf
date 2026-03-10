resource "aws_lb_target_group_attachment" "app_target_group_attachment" {
  target_group_arn = aws_lb_target_group.app_target_group.arn
  target_id = var.ec2_instance_id
  port = 3000
}