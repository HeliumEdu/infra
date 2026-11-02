module "datadog" {
  source = "../../modules/global/datadog"

  aws_account_id = var.AWS_ACCOUNT_ID
  github_pat     = var.GITHUB_PAT
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

