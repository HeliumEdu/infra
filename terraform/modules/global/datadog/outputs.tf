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
    # Liveness (24h traffic dead-man's switches)
    low_email_traffic = datadog_monitor.low_email_traffic.id
    low_push_traffic  = datadog_monitor.low_push_notification_traffic.id
    low_auth_traffic  = datadog_monitor.auth_low_traffic.id

    # Immediate/Diagnostic (help understand why something is broken)
    email_failures         = datadog_monitor.email_delivery_failures.id
    push_failures          = datadog_monitor.push_delivery_failures.id
    server_errors          = datadog_monitor.server_error_spike.id
    calendar_sync_failures = datadog_monitor.calendar_sync_failures.id
    firebase_failures      = datadog_monitor.firebase_oauth_failures.id
    task_failures          = datadog_monitor.task_failures.id
    scheduled_task_stalled = datadog_monitor.scheduled_task_not_running.id
    api_5xx_spike          = datadog_monitor.api_5xx_spike.id
    api_5xx_alb_child      = datadog_monitor.api_5xx_alb_child.id
    frontend_5xx_spike     = datadog_monitor.frontend_5xx_spike.id
    client_4xx_anomaly     = datadog_monitor.client_4xx_anomaly.id
    ses_bounce_rate        = datadog_monitor.ses_bounce_rate.id
    ses_complaint_rate     = datadog_monitor.ses_complaint_rate.id
    support_contact_abuse  = datadog_monitor.support_contact_abuse.id
    reminder_dispatch_sat  = datadog_monitor.reminder_dispatch_saturation.id

    # Config-focused (sustained issues requiring config changes)
    api_slow_responses       = datadog_monitor.api_slow_responses.id
    high_priority_queue_wait = datadog_monitor.high_priority_queue_wait.id
    importexport_slow        = datadog_monitor.importexport_slow_responses.id
    task_duration_degraded   = datadog_monitor.task_duration_degraded.id

    # Capacity (a finite resource nearing its ceiling)
    ecs_cpu         = datadog_monitor.ecs_cpu.id
    ecs_memory      = datadog_monitor.ecs_memory.id
    rds_cpu         = datadog_monitor.rds_cpu.id
    rds_connections = datadog_monitor.rds_connections.id
    rds_storage     = datadog_monitor.rds_storage.id
    redis_memory    = datadog_monitor.redis_memory.id
  }
}
