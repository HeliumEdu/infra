resource "datadog_monitor" "low_email_traffic" {
  name     = "Low Email Traffic"
  type     = "query alert"
  query    = "sum(last_4h):sum:platform.action.email.sent{env:prod}.as_count() < 5"
  message  = <<-EOT
    Emails sent are below {{ threshold }} in the last 4 hours. The Helium platform or AWS SES service may need investigation.
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "token_api_low_traffic" {
  name     = "Low Login Traffic (/token)"
  type     = "query alert"
  query    = "sum(last_4h):sum:platform.request{env:prod, status_code:200, method:post, path:auth.token}.as_count() < 5"
  message  = <<-EOT
    Successful logins on /token are below {{ threshold }} in the last 4 hours.
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "feed_reindex_time_exceeded" {
  name     = "Feed Reindex Time Exceeded Threshold"
  type     = "query alert"
  query    = "sum(last_1h):max:platform.task.timing.avg{env:prod, name:feed.reindex} / 1000 > 300"
  message  = <<-EOT
    Reindex of Feeds in the cache exceeded {{ threshold }} seconds.

    Notify: @support@heliumedu.com
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 120
    critical = 300
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "token_refresh_api_low_traffic" {
  name     = "Low Session Refresh Traffic (/token/refresh)"
  type     = "query alert"
  query    = "sum(last_4h):sum:platform.request{env:prod, status_code:200, method:post, path:auth.token.refresh}.as_count() < 5"
  message  = <<-EOT
    Successful session refreshes on /token/refresh are below {{ threshold }} in the last 4 hours.
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "low_push_notification_traffic" {
  name     = "Low Push Notification Traffic"
  type     = "query alert"
  query    = "sum(last_4h):sum:platform.action.push.sent{env:prod}.as_count() < 5"
  message  = <<-EOT
    Push notifications sent are below {{ threshold }} in the last 4 hours. The Helium platform or Firebase service may need investigation.
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "email_delivery_failures" {
  name     = "Email Delivery Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.action.email.failed{env:prod}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} email delivery failures detected in the last hour. AWS SES or the email sending service should be investigated.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "push_delivery_failures" {
  name     = "Push Notification Delivery Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.action.push.failed{env:prod}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} push notification delivery failures detected in the last hour. Firebase Cloud Messaging should be investigated.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "server_error_spike" {
  name     = "API 5xx Error Spike - App (child)"
  type     = "query alert"
  query    = "sum(last_5m):default_zero(sum:platform.request{env:prod, status_code:500}.as_count()) > 10"
  message  = "App-level 500s child monitor - see 'API 5xx Error Spike' composite monitor for alerts."
  priority = 3

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 10
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "calendar_sync_failures" {
  name     = "Calendar Sync Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.feed.ical.failed{env:prod}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} calendar sync failures detected in the last hour. iCal feed fetching should be investigated.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "firebase_oauth_failures" {
  name     = "Firebase/OAuth Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.external.firebase.failed{env:prod}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} Firebase/OAuth failures detected in the last hour. OAuth integration should be investigated.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "task_failures" {
  name     = "Background Task Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.task.failed{env:prod}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} background task failures detected in the last hour. Celery workers and task processing should be investigated.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "api_undersized" {
  name     = "API Tasks Undersized"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.ecs.cpuutilization{clustername:helium_prod, servicename:*api*} > 60"
  message  = <<-EOT
    API CPU utilization has averaged above {{ threshold }}% for the last 24 hours.

    This sustained high utilization indicates your API tasks are undersized. Consider:
    - Increasing task CPU allocation in ECS task definition
    - Increasing Gunicorn workers/threads if memory allows
    - Raising platform_host_min for more baseline capacity

    Notify: @support@heliumedu.com
  EOT
  priority = 4

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 50
    critical = 60
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "worker_undersized" {
  name     = "Worker Tasks Undersized"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.ecs.cpuutilization{clustername:helium_prod, servicename:*worker*} > 60"
  message  = <<-EOT
    Worker CPU utilization has averaged above {{ threshold }}% for the last 24 hours.

    This sustained high utilization indicates your worker tasks are undersized. Consider:
    - Increasing task CPU allocation in ECS task definition
    - Increasing Celery concurrency if memory allows
    - Raising platform_worker_min for more baseline capacity

    Notify: @support@heliumedu.com
  EOT
  priority = 4

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 50
    critical = 60
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "api_autoscale_triggered" {
  name     = "API Autoscaling Triggered"
  type     = "query alert"
  query    = "avg(last_5m):avg:aws.ecs.service.running{clustername:helium_prod, servicename:*api*} > 1"
  message  = <<-EOT
    API service has scaled to {{ value }} tasks (above baseline of 1). This is informational.

    @support@heliumedu.com
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 1
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "worker_autoscale_triggered" {
  name     = "Worker Autoscaling Triggered"
  type     = "query alert"
  query    = "avg(last_5m):avg:aws.ecs.service.running{clustername:helium_prod, servicename:*worker*} > 1"
  message  = <<-EOT
    Worker service has scaled to {{ value }} tasks (above baseline of 1). This is informational.

    @support@heliumedu.com
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 1
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "api_slow_responses" {
  name     = "API Response Times Degraded"
  type     = "query alert"
  query    = "avg(last_1d):avg:platform.request.timing.95percentile{env:prod} / 1000 > 3000"
  message  = <<-EOT
    API p95 response time has averaged above {{ threshold }}ms for the last 24 hours.

    Sustained slow responses indicate a configuration or optimization issue:
    - Database queries need optimization (check Sentry for N+1, slow queries)
    - API tasks may be undersized
    - Missing database indexes

    Notify: @support@heliumedu.com
  EOT
  priority = 4

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 2000
    critical = 3000
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "api_capacity_config" {
  name     = "API Capacity Configuration Wrong"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.applicationelb.active_connection_count{name:helium-prod} / avg:aws.ecs.service.running{clustername:helium_prod, servicename:*api*} > 18"
  message  = <<-EOT
    Average connections per API task has been above {{ threshold }} for the last 24 hours.

    With 24 concurrent connections per task (3 workers × 8 threads), sustained high utilization means your capacity configuration needs adjustment:
    - Increase platform_host_min for more baseline capacity
    - Increase Gunicorn workers/threads per task (via GUNICORN_WORKERS / GUNICORN_THREADS env vars)
    - Increase task CPU/memory to support more workers

    Notify: @support@heliumedu.com
  EOT
  priority = 4

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 14
    critical = 18
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "redis_needs_upgrade" {
  name     = "Redis Instance Needs Upgrade"
  type     = "query alert"
  query    = "avg(last_1d):100 - (avg:aws.elasticache.freeable_memory{name:helium-prod} / 1000000000 * 100) > 70"
  message  = <<-EOT
    Redis memory utilization has averaged above {{ threshold }}% for the last 24 hours.

    Sustained high memory usage indicates configuration changes needed:
    - Review cache TTL settings (items not expiring)
    - Check for Celery queue backlog
    - Consider upgrading ElastiCache instance size

    Notify: @support@heliumedu.com
  EOT
  priority = 4

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 60
    critical = 70
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "api_5xx_alb_child" {
  name    = "API 5xx Error Spike - ALB (child)"
  type    = "query alert"
  query   = "sum(last_5m):(sum:aws.applicationelb.httpcode_elb_5xx{name:helium-prod}.as_count() + sum:aws.applicationelb.httpcode_target_5xx{name:helium-prod}.as_count()) > 5"
  message = "ALB 5xx child monitor - see 'API 5xx Error Spike' composite monitor for alerts."
  priority = 3

  include_tags        = false
  on_missing_data     = "resolve"
  require_full_window = false

  monitor_thresholds {
    warning  = 1
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "api_5xx_spike" {
  name    = "API 5xx Error Spike"
  type    = "composite"
  query   = "${datadog_monitor.server_error_spike.id} || ${datadog_monitor.api_5xx_alb_child.id}"
  message = <<-EOT
    API 5xx error spike detected. Investigate:
    - App-level 500s: the platform may be experiencing errors (check Sentry)
    - ALB ELB 5xx: ALB-generated errors (502/503/504) — ECS targets may be unhealthy or unreachable
    - ALB Target 5xx: backend returning 5xx as seen by the ALB

    Notify: @support@heliumedu.com
  EOT
  priority = 2

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "frontend_5xx_spike" {
  name    = "Frontend 5xx Error Rate Elevated"
  type    = "query alert"
  query   = "avg(last_5m):sum:aws.cloudfront.5xx_error_rate{environment:prod}.weighted() > 5"
  message = <<-EOT
    CloudFront 5xx error rate has exceeded {{ threshold }}% in the last 5 minutes. The frontend S3 origin may be unavailable or misconfigured.

    Notify: @support@heliumedu.com
  EOT
  priority = 2

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 1
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "ses_bounce_rate" {
  name     = "SES Bounce Rate Elevated"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.ses.reputation_bounce_rate{*} > 0.025"
  message  = <<-EOT
    SES account bounce rate has exceeded 2.5% over the last 24 hours. AWS begins reviewing accounts at 5% and may suspend sending at 10%.

    Investigate recent email sends for invalid addresses or unexpected bounce patterns.

    Notify: @support@heliumedu.com
  EOT
  priority = 2

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 0.025
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "ses_complaint_rate" {
  name     = "SES Complaint Rate Elevated"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.ses.reputation_complaint_rate{*} > 0.0005"
  message  = <<-EOT
    SES account complaint rate has exceeded 0.05% over the last 24 hours. AWS begins reviewing accounts at 0.1% and may suspend sending at 0.5%.

    Investigate recent email sends for unexpected complaint patterns. Do not suppress users based on complaints — investigate for bugs or unexpected send volume instead.

    Notify: @support@heliumedu.com
  EOT
  priority = 2

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    critical = 0.0005
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "rds_connection_config" {
  name     = "RDS Connection Configuration Wrong"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.rds.database_connections{name:helium-prod} > 55"
  message  = <<-EOT
    RDS connections have averaged above {{ threshold }} for the last 24 hours (max ~66 for db.t4g.micro).

    Sustained high connection count indicates configuration changes needed:
    - Reduce Gunicorn workers/threads or Celery concurrency
    - Check for connection leaks in application code
    - Consider upgrading RDS instance size (and updating this monitor's thresholds)

    Notify: @support@heliumedu.com
  EOT
  priority = 4

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 45
    critical = 55
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}
