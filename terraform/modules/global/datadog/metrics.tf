locals {
  user_distribution_metrics = toset([
    "platform.users.data.attachments_per_user",
    "platform.users.data.courses_per_group",
    "platform.users.data.events_per_user",
    "platform.users.data.external_calendars_per_user",
    "platform.users.data.graded_homework_per_course",
    "platform.users.data.homework_per_course",
    "platform.users.data.homework_per_user",
    "platform.users.data.notes_per_user",
    "platform.users.data.reminders_per_user",
    "platform.users.data.resources_per_user",
    "platform.users.engagement.completions_per_user",
    "platform.users.engagement.graded_homework_per_user",
  ])
}

resource "datadog_metric_tag_configuration" "user_distribution" {
  for_each = local.user_distribution_metrics

  metric_name         = each.value
  metric_type         = "distribution"
  tags                = ["env", "staff", "window", "entity"]
  include_percentiles = true
}
