data "tfe_workspace" "targets" {
  for_each = { for name, cfg in var.workspaces : name => cfg if cfg.enabled }

  name         = each.key
  organization = var.organization
}

resource "tfe_notification_configuration" "run_failures" {
  for_each = data.tfe_workspace.targets

  name             = "${each.key}-run-failures"
  workspace_id     = each.value.id
  destination_type = "email"
  enabled          = true
  triggers         = var.triggers
  email_user_ids   = [var.recipient_user_id]
}
