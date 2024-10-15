output "frontend_target_group" {
  value = aws_lb_target_group.frontend.arn
}

output "platform_target_group" {
  value = aws_lb_target_group.platform.arn
}