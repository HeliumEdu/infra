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

module "vpc" {
  source = "../../modules/vpc"
}


module "alb" {
  source = "../../modules/alb"

  environment                   = var.environment
  environment_prefix            = var.environment_prefix
  route53_heliumedu_com_zone_id = module.route53.heliumedu_com_zone_id
  security_group                = module.vpc.http_s_sg_id
  subnet_ids                    = module.vpc.subnet_ids
  helium_vpc_id                 = module.vpc.vpc_id
  heliumedu_com_cert_arn        = module.certificatemanager.heliumedu_com_cert_arn
}

# TODO: commented out until the multiple database are split off the existing RDS cluster
# module "rds" {
#   source = "../../modules/rds"
#
#   environment = var.environment
#   subnet_ids  = module.vpc.subnet_ids
#   mysql_sg    = module.vpc.mysql_sg
#   password    = var.PLATFORM_DB_USER
#   username    = var.PLATFORM_DB_PASSWORD
# }

module "elasticache" {
  source = "../../modules/elasticache"

  environment    = var.environment
  subnet_ids     = module.vpc.subnet_ids
  elasticache_sg = module.vpc.elasticache_sg
}

module "ecs" {
  source = "../../modules/ecs"

  helium_version        = var.helium_version
  environment           = var.environment
  aws_account_id        = var.aws_account_id
  aws_region            = var.aws_region
  datadog_api_key       = var.DD_API_KEY
  http_frontend         = module.vpc.http_sg_frontend
  http_platform         = module.vpc.http_sg_platform
  frontend_target_group = module.alb.frontend_target_group
  platform_target_group = module.alb.platform_target_group
  subnet_ids            = module.vpc.subnet_ids
}

module "s3" {
  source = "../../modules/s3"

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

module "secretsmanager" {
  source = "../../modules/secretsmanager"

  environment               = var.environment
  aws_account_id            = var.aws_account_id
  aws_region                = var.aws_region
  datadog_api_key           = var.DD_API_KEY
  datadog_app_key           = var.DD_APP_KEY
  redis_host                = var.PLATFORM_REDIS_HOST
  db_host                   = var.PLATFORM_DB_HOST
  db_user                   = var.PLATFORM_DB_USER
  db_password               = var.PLATFORM_DB_PASSWORD
  platform_secret           = var.PLATFORM_SECRET_PROD
  rollbar_access_token      = var.ROLLBAR_API_KEY
  s3_user_access_key_id     = module.s3.s3_access_key_id
  s3_user_secret_access_key = module.s3.s3_access_key_secret
  smtp_email_user           = module.ses.smtp_username
  smtp_email_password       = module.ses.smtp_password
  twilio_account_sid        = var.TWILIO_ACCOUNT_SID
  twilio_auth_token         = var.TWILIO_AUTH_TOKEN
  twilio_phone_number       = module.twilio.helium_phone_number
}

module "twilio" {
  source = "../../modules/twilio"

  environment              = var.environment
  helium_twiml_handler_url = var.helium_twiml_handler_url
  ci_twiml_handler_url     = var.ci_twiml_handler_url
}