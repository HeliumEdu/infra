output "dashboard_url" {
  description = "URL of the Helium Heads Up dashboard"
  value       = "https://app.datadoghq.com${datadog_dashboard.helium_heads_up.url}"
}

output "dashboard_id" {
  description = "ID of the Helium Heads Up dashboard"
  value       = datadog_dashboard.helium_heads_up.id
}

output "monitor_ids" {
  description = "Map of monitor names to IDs"
  value = {
    low_email_traffic      = datadog_monitor.low_email_traffic.id
    low_push_traffic       = datadog_monitor.low_push_notification_traffic.id
    low_login_traffic      = datadog_monitor.token_api_low_traffic.id
    low_session_traffic    = datadog_monitor.token_refresh_api_low_traffic.id
    feed_reindex_slow      = datadog_monitor.feed_reindex_time_exceeded.id
    email_failures         = datadog_monitor.email_delivery_failures.id
    push_failures          = datadog_monitor.push_delivery_failures.id
    server_errors          = datadog_monitor.server_error_spike.id
    calendar_sync_failures = datadog_monitor.calendar_sync_failures.id
    firebase_failures      = datadog_monitor.firebase_oauth_failures.id
    task_failures          = datadog_monitor.task_failures.id
  }
}
