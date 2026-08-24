output "heliumedu_com_cert_arn" {
  value = aws_acm_certificate_validation.heliumedu_com_cert_validation.certificate_arn
}

output "heliumstudy_com_cert_arn" {
  value = aws_acm_certificate_validation.heliumstudy_com_cert_validation.certificate_arn
}
