output "https_listener_arn" {
  value = aws_lb_listener.https.arn
}

output "blue_target_group_arn" {
  value = aws_lb_target_group.blue_target_group.arn
}

output "green_target_group_arn" {
  value = aws_lb_target_group.green_target_group.arn
}