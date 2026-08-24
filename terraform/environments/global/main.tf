module "datadog" {
  source = "../../modules/global/datadog"

  aws_account_id = var.AWS_ACCOUNT_ID
}

data "tfe_organization_membership" "notification_recipient" {
  organization = "HeliumEdu"
  email        = "support@heliumedu.com"
}

module "hcp_notifications" {
  source = "../../modules/global/hcp"

  organization      = "HeliumEdu"
  recipient_user_id = data.tfe_organization_membership.notification_recipient.user_id

  workspaces = {
    "global"    = { enabled = true }
    "prod"      = { enabled = true }
    "dev"       = { enabled = var.dev_env_enabled }
    "dev-local" = { enabled = true }
  }
}

removed {
  from = aws_s3_bucket.www

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_s3_bucket_public_access_block.www

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_s3_bucket_policy.www

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_s3_bucket_cors_configuration.www

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_s3_bucket_website_configuration.www

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_acm_certificate.marketing

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_route53_record.marketing_cert_validation

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_acm_certificate_validation.marketing

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_cloudfront_distribution.marketing

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_route53_record.www_heliumedu_com

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_s3_bucket.landing_redirect

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_s3_bucket_public_access_block.landing_redirect

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_s3_bucket_policy.landing_redirect

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_s3_bucket_website_configuration.landing_redirect

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_cloudfront_distribution.landing_redirect

  lifecycle {
    destroy = false
  }
}

removed {
  from = aws_route53_record.landing

  lifecycle {
    destroy = false
  }
}
