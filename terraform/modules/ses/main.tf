resource "aws_iam_user" "smtp_user" {
  name = "${var.environment}_helium_smtp_user"
}

resource "aws_iam_access_key" "smtp_access_key" {
  user = aws_iam_user.smtp_user.name
}

output "smtp_username" {
  value = aws_iam_access_key.smtp_access_key.id
}

output "smtp_password" {
  sensitive = true
  value     = aws_iam_access_key.smtp_access_key.ses_smtp_password_v4
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    resources = ["*"]
    actions   = ["ses:SendRawEmail"]
  }
}

resource "aws_iam_policy" "ses_sender" {
  name        = "AmazonSesSendingAccess"
  policy      = data.aws_iam_policy_document.ses_sender.json
}

resource "aws_ses_domain_identity" "heliumedu_com_identity" {
  domain = "${var.environment_prefix}heliumedu.com"
}

resource "aws_route53_record" "heliumedu_com_amazonses_verification_record" {
  zone_id = var.route53_heliumedu_com_zone_id
  name    = "_amazonses.${var.environment_prefix}heliumedu.com"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.heliumedu_com_identity.verification_token]
}

resource "aws_ses_domain_identity" "heliumedu_dev_identity" {
  domain = "heliumedu.dev"
}

resource "aws_route53_record" "heliumedu_dev_amazonses_verification_record" {
  zone_id = var.route53_heliumedu_dev_zone_id
  name    = "_amazonses.${var.environment_prefix}heliumedu.dev"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.heliumedu_dev_identity.verification_token]
}

resource "aws_ses_receipt_rule_set" "default_rule_set" {
  rule_set_name = "${var.environment}-rule-set"
}

resource "aws_ses_receipt_rule" "store_s3" {
  name          = "heliumedu-ci-test-email-to-s3"
  rule_set_name = "${var.environment}-rule-set"
  recipients = ["heliumedu-ci-test@${var.environment_prefix}heliumedu.dev"]
  enabled       = true
  scan_enabled  = false

  s3_action {
    bucket_name       = "heliumedu.${var.environment}"
    object_key_prefix = "ci.email/heliumedu-ci-test"
    position          = 1
  }
}