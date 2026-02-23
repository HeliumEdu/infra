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
    no_emails_sent         = datadog_monitor.no_emails_sent.id
    no_texts_sent          = datadog_monitor.no_texts_sent.id
    no_push_sent           = datadog_monitor.no_push_notifications_sent.id
    token_api_down         = datadog_monitor.token_api_down.id
    token_refresh_api_down = datadog_monitor.token_refresh_api_down.id
    feed_reindex_slow      = datadog_monitor.feed_reindex_time_exceeded.id
  }
}
