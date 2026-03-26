output "configuration_set_name" {
  value = aws_sesv2_configuration_set.helium.configuration_set_name
}

output "smtp_username" {
  sensitive = true
  value     = aws_iam_access_key.smtp_access_key.id
}

output "smtp_password" {
  sensitive = true
  value     = aws_iam_access_key.smtp_access_key.ses_smtp_password_v4
}