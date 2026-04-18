variable "organization" {
  description = "The HCP Terraform organization name"
  type        = string
}

variable "recipient_user_id" {
  description = "HCP user ID that will receive run failure notifications"
  type        = string
}

variable "workspaces" {
  description = "Map of workspace name to configuration. Only workspaces with enabled = true receive a notification configuration."
  type        = map(object({ enabled = bool }))
}

variable "triggers" {
  description = "HCP Terraform run events that will trigger a notification"
  type        = list(string)
  default     = ["run:errored", "run:needs_attention"]
}
