output "platform_target_group" {
  value = aws_lb_target_group.platform.arn
}

output "platform_api_target_group" {
  value = aws_lb_target_group.platform_api.arn

  # ECS won't attach a target group until a listener routes to it
  depends_on = [aws_lb_listener_rule.platform_api]
}

output "api_lb_arn" {
  value = aws_lb.api.arn
}

output "api_lb_dns_name" {
  value = aws_lb.api.dns_name
}
