module "route53" {
  source = "../../modules/route53"

  environment        = var.environment
  environment_prefix = var.environment_prefix
}

module "certificatemanager" {
  source = "../../modules/certificatemanager"

  environment                   = var.environment
  environment_prefix            = var.environment_prefix
  route53_heliumedu_com_zone_id = module.route53.heliumedu_com_zone_id
  route53_heliumedu_dev_zone_id = module.route53.heliumedu_dev_zone_id
}

module "s3" {
  source = "../../modules/s3/ci_bucket"

  aws_account_id = var.aws_account_id
  environment    = var.environment
}

module "ses" {
  source = "../../modules/ses"

  environment                   = var.environment
  environment_prefix            = var.environment_prefix
  route53_heliumedu_com_zone_id = module.route53.heliumedu_com_zone_id
  route53_heliumedu_dev_zone_id = module.route53.heliumedu_dev_zone_id
}

module "twilio" {
  source = "../../modules/twilio"

  environment              = var.environment
  helium_twiml_handler_url = var.helium_twiml_handler_url
  ci_twiml_handler_url     = var.ci_twiml_handler_url
}