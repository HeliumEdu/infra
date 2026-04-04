import {
  to = module.datadog.datadog_integration_aws_account.helium
  id = "562129510549:aws"
}

module "datadog" {
  source = "../../modules/global/datadog"

  aws_account_id = var.aws_account_id
}
