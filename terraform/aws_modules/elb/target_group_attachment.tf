resource "aws_lb_target_group_attachment" "blue_target_group_attachment" {
  target_group_arn = aws_lb_target_group.blue_target_group.arn
  target_id = var.ec2_instance_id
  port = 3000
}

resource "aws_lb_target_group_attachment" "green_target_group_attachment" {
  target_group_arn = aws_lb_target_group.green_target_group.arn
  target_id = var.ec2_instance_id
  port = 3001
}