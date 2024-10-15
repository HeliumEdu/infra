data "aws_caller_identity" "current" {}

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
}

module "route53" {
  source = "../../modules/route53"

  environment_prefix = var.environment_prefix
}

module "certificatemanager" {
  source = "../../modules/certificatemanager"

  environment_prefix            = var.environment_prefix
  route53_heliumedu_com_zone_id = module.route53.heliumedu_com_zone_id
  route53_heliumedu_dev_zone_id = module.route53.heliumedu_dev_zone_id
}

module "vpc" {
  source = "../../modules/vpc"

  environment = var.environment
  aws_region  = var.aws_region
  region_azs  = var.region_azs
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

module "rds" {
  source = "../../modules/rds"

  environment = var.environment
  subnet_ids  = module.vpc.subnet_ids
  mysql_sg    = module.vpc.mysql_sg
  multi_az    = var.db_multi_az
}

module "elasticache" {
  source = "../../modules/elasticache"

  environment     = var.environment
  subnet_ids      = module.vpc.subnet_ids
  elasticache_sg  = module.vpc.elasticache_sg
  num_cache_nodes = var.num_cache_nodes
}

module "ecr" {
  source = "../../modules/ecr"
}

module "ecs" {
  source = "../../modules/ecs"

  helium_version                   = var.helium_version
  frontend_host_count              = var.frontend_host_count
  platform_host_count              = var.platform_host_count
  frontend_repository_uri          = module.ecr.frontend_repository_uri
  platform_resource_repository_uri = module.ecr.platform_resource_repository_uri
  platform_api_repository_uri      = module.ecr.platform_api_repository_uri
  platform_worker_repository_uri   = module.ecr.platform_worker_repository_uri
  environment                      = var.environment
  environment_prefix               = var.environment_prefix
  aws_account_id                   = local.aws_account_id
  aws_region                       = var.aws_region
  datadog_api_key                  = var.DD_API_KEY
  http_frontend                    = module.vpc.http_sg_frontend
  http_platform                    = module.vpc.http_sg_platform
  frontend_target_group            = module.alb.frontend_target_group
  platform_target_group            = module.alb.platform_target_group
  subnet_ids                       = module.vpc.subnet_ids
}

module "s3" {
  source = "../../modules/s3"

  aws_account_id = local.aws_account_id
  environment    = var.environment
}

module "ses" {
  source = "../../modules/ses"

  environment                   = var.environment
  environment_prefix            = var.environment_prefix
  aws_region                    = var.aws_region
  heliumedu_s3_bucket_name      = module.s3.heliumedu_s3_bucket_name
  route53_heliumedu_com_zone_id = module.route53.heliumedu_com_zone_id
  route53_heliumedu_dev_zone_id = module.route53.heliumedu_dev_zone_id
}

module "secretsmanager" {
  source = "../../modules/secretsmanager"

  environment               = var.environment
  aws_account_id            = local.aws_account_id
  aws_region                = var.aws_region
  task_execution_role_arn   = module.ecs.task_execution_role_arn
  datadog_api_key           = var.DD_API_KEY
  datadog_app_key           = var.DD_APP_KEY
  redis_host                = module.elasticache.elasticache_host
  db_host                   = module.rds.db_host
  db_user                   = module.rds.db_username
  db_password               = module.rds.db_password
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
  helium_area_code         = var.helium_area_code
  ci_area_code             = var.ci_area_code
  helium_twiml_handler_url = var.helium_twiml_handler_url
  ci_twiml_handler_url     = var.ci_twiml_handler_url
}