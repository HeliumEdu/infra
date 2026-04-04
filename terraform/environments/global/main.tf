module "datadog" {
  source = "../../modules/global/datadog"

  aws_account_id = var.aws_account_id
}
