resource "aws_iam_user" "smtp_user" {
  name = "helium-${var.environment}-smtp-user"
}

resource "aws_iam_access_key" "smtp_access_key" {
  user = aws_iam_user.smtp_user.name
}

data "aws_iam_policy_document" "ses_sender" {
  statement {
    resources = ["*"]
    actions = ["ses:SendRawEmail"]

    condition {
      test     = "StringLike"
      variable = "ses:FromAddress"
      values = ["*@${var.environment_prefix}heliumedu.com"]
    }
  }
}

resource "aws_iam_policy" "ses_sender" {
  name   = "helium-${var.environment}-ses-send-access"
  policy = data.aws_iam_policy_document.ses_sender.json
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

resource "aws_ses_domain_dkim" "heliumedu_com_dkim" {
  domain = aws_ses_domain_identity.heliumedu_com_identity.domain
}

resource "aws_route53_record" "heliumedu_com_amazonses_dkim_record" {
  count   = 3
  zone_id = var.route53_heliumedu_com_zone_id
  name    = "${aws_ses_domain_dkim.heliumedu_com_dkim.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.heliumedu_com_dkim.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_ses_domain_identity" "heliumedu_dev_identity" {
  domain = "${var.environment_prefix}heliumedu.dev"
}

resource "aws_route53_record" "heliumedu_dev_amazonses_verification_record" {
  zone_id = var.route53_heliumedu_dev_zone_id
  name    = "_amazonses.${var.environment_prefix}heliumedu.dev"
  type    = "TXT"
  ttl     = "600"
  records = [aws_ses_domain_identity.heliumedu_dev_identity.verification_token]
}

resource "aws_ses_domain_dkim" "heliumedu_dev_dkim" {
  domain = aws_ses_domain_identity.heliumedu_dev_identity.domain
}

resource "aws_route53_record" "heliumedu_dev_amazonses_dkim_record" {
  count   = 3
  zone_id = var.route53_heliumedu_dev_zone_id
  name    = "${aws_ses_domain_dkim.heliumedu_dev_dkim.dkim_tokens[count.index]}._domainkey"
  type    = "CNAME"
  ttl     = "600"
  records = ["${aws_ses_domain_dkim.heliumedu_dev_dkim.dkim_tokens[count.index]}.dkim.amazonses.com"]
}

resource "aws_route53_record" "heliumedu_dev_inbound_smtp" {
  zone_id = var.route53_heliumedu_dev_zone_id
  name    = "${var.environment_prefix}heliumedu.dev"
  type    = "MX"
  ttl     = "600"
  records = ["10 inbound-smtp.${var.aws_region}.amazonaws.com"]
}

resource "aws_ses_receipt_rule_set" "helium_rule_set" {
  rule_set_name = "helium-${var.environment}-rule-set"
}

resource "aws_ses_active_receipt_rule_set" "main" {
  rule_set_name = aws_ses_receipt_rule_set.helium_rule_set.rule_set_name
}

resource "aws_ses_receipt_rule" "store_s3" {
  name          = "heliumedu-ci-${var.environment}-test-email-to-s3"
  rule_set_name = aws_ses_receipt_rule_set.helium_rule_set.rule_set_name
  recipients = ["heliumedu-ci-test@${var.environment_prefix}heliumedu.dev"]
  enabled       = true
  scan_enabled  = false

  s3_action {
    bucket_name       = var.heliumedu_s3_bucket_name
    object_key_prefix = "ci.email/heliumedu-ci-test"
    position          = 1
  }
}