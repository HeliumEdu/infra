output "dashboard_url" {
  description = "URL of the Helium Heads Up dashboard"
  value       = "https://app.datadoghq.com${datadog_dashboard.helium_heads_up.url}"
}

output "dashboard_id" {
  description = "ID of the Helium Heads Up dashboard"
  value       = datadog_dashboard.helium_heads_up.id
}

output "user_behavior_dashboard_url" {
  description = "URL of the Helium User Behavior dashboard"
  value       = "https://app.datadoghq.com${datadog_dashboard.helium_user_behavior.url}"
}

output "user_behavior_dashboard_id" {
  description = "ID of the Helium User Behavior dashboard"
  value       = datadog_dashboard.helium_user_behavior.id
}

output "monitor_ids" {
  description = "Map of monitor names to IDs"
  value = {
    # Informational (no email, useful for trends)
    low_email_traffic      = datadog_monitor.low_email_traffic.id
    low_push_traffic       = datadog_monitor.low_push_notification_traffic.id
    low_login_traffic      = datadog_monitor.token_api_low_traffic.id
    low_session_traffic    = datadog_monitor.token_refresh_api_low_traffic.id
    api_autoscale          = datadog_monitor.api_autoscale_triggered.id
    worker_autoscale       = datadog_monitor.worker_autoscale_triggered.id

    # Immediate/Diagnostic (help understand why something is broken)
    feed_reindex_slow      = datadog_monitor.feed_reindex_time_exceeded.id
    email_failures         = datadog_monitor.email_delivery_failures.id
    push_failures          = datadog_monitor.push_delivery_failures.id
    server_errors          = datadog_monitor.server_error_spike.id
    calendar_sync_failures = datadog_monitor.calendar_sync_failures.id
    firebase_failures      = datadog_monitor.firebase_oauth_failures.id
    task_failures          = datadog_monitor.task_failures.id

    # Config-focused (sustained issues requiring config changes)
    api_undersized         = datadog_monitor.api_undersized.id
    worker_undersized      = datadog_monitor.worker_undersized.id
    api_slow_responses     = datadog_monitor.api_slow_responses.id
    api_capacity_config    = datadog_monitor.api_capacity_config.id
    redis_needs_upgrade    = datadog_monitor.redis_needs_upgrade.id
    rds_connection_config  = datadog_monitor.rds_connection_config.id
  }
}
