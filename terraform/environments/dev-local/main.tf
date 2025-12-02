data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

module "route53" {
  source = "../../modules/route53"

  environment        = var.environment
  environment_prefix = var.environment_prefix
  parent_com_zone_id = var.prod_com_zone_id
  parent_dev_zone_id = var.prod_dev_zone_id
}

module "certificatemanager" {
  source = "../../modules/certificatemanager"

  route53_heliumedu_com_zone_id   = module.route53.heliumedu_com_zone_id
  route53_heliumedu_com_zone_name = module.route53.heliumedu_com_zone_name
  route53_heliumedu_dev_zone_id   = module.route53.heliumedu_dev_zone_id
  route53_heliumedu_dev_zone_name = module.route53.heliumedu_dev_zone_name
}

module "s3" {
  source = "../../modules/s3/ci_bucket"

  aws_account_id = local.aws_account_id
  environment    = var.environment
}

module "ses" {
  source = "../../modules/ses"

  environment                     = var.environment
  aws_region                      = var.aws_region
  heliumedu_s3_bucket_name        = module.s3.heliumedu_s3_bucket_name
  route53_heliumedu_com_zone_id   = module.route53.heliumedu_com_zone_id
  route53_heliumedu_com_zone_name = module.route53.heliumedu_com_zone_name
  route53_heliumedu_dev_zone_id   = module.route53.heliumedu_dev_zone_id
  route53_heliumedu_dev_zone_name = module.route53.heliumedu_dev_zone_name
}

module "secretsmanager" {
  source = "../../modules/secretsmanager/ci_creds"

  environment               = var.environment
  smtp_email_user           = module.ses.smtp_username
  smtp_email_password       = module.ses.smtp_password
  s3_user_access_key_id     = module.s3.s3_access_key_id
  s3_user_secret_access_key = module.s3.s3_access_key_secret
}

module "twilio" {
  source = "../../modules/twilio"

  environment              = var.environment
  helium_twiml_handler_url = var.HELIUM_TWIML_HANDLER_URL
  ci_twiml_handler_url     = var.CI_TWIML_HANDLER_URL
  helium_area_code         = var.helium_area_code
  ci_area_code             = var.ci_area_code
}
