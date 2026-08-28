resource "datadog_monitor" "low_email_traffic" {
  name     = "Low Email Traffic"
  type     = "query alert"
  query    = "sum(last_24h):sum:platform.action.email.sent{env:prod}.as_count() < 5"
  message  = <<-EOT
    Emails sent are below {{ threshold }} in the last 24 hours. The Helium platform or AWS SES service may need investigation.

    Notify: @support@heliumedu.com
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "token_api_low_traffic" {
  name     = "Low Login Traffic (/token)"
  type     = "query alert"
  query    = "sum(last_24h):sum:platform.request{env:prod, status_code:200, method:post, path:auth.token}.as_count() < 5"
  message  = <<-EOT
    Successful logins on /token are below {{ threshold }} in the last 24 hours.

    Notify: @support@heliumedu.com
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "token_refresh_api_low_traffic" {
  name     = "Low Session Refresh Traffic (/token/refresh)"
  type     = "query alert"
  query    = "sum(last_24h):sum:platform.request{env:prod, status_code:200, method:post, path:auth.token.refresh}.as_count() < 5"
  message  = <<-EOT
    Successful session refreshes on /token/refresh are below {{ threshold }} in the last 24 hours.

    Notify: @support@heliumedu.com
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "low_push_notification_traffic" {
  name     = "Low Push Notification Traffic"
  type     = "query alert"
  query    = "sum(last_24h):sum:platform.action.push.sent{env:prod}.as_count() < 1"
  message  = <<-EOT
    Push notifications sent are below {{ threshold }} in the last 24 hours. The Helium platform or Firebase service may need investigation.

    Notify: @support@heliumedu.com
  EOT
  priority = 5

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 5
    critical = 1
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
  renotify_interval   = 1440

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "push_delivery_failures" {
  name     = "Push Notification Delivery Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.action.push.failed{env:prod,!reason:unregistered}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} push notification delivery failures detected in the last hour, excluding tokens that were simply retired. Firebase Cloud Messaging should be investigated.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

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
  renotify_interval   = 1440

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
  renotify_interval   = 1440

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "task_failures" {
  name     = "Background Task Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.task.failed{env:prod} by {name}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} failures of the background task {{{{name.name}}}} in the last hour. Celery workers and task processing should be investigated.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = true
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "scheduled_task_not_running" {
  name     = "Scheduled Task Not Running"
  type     = "query alert"
  query    = "sum(last_2d):sum:platform.task.timing.count{env:prod,name IN (token.refresh.purge,push.token.purge,metrics.queue-depth,user.dangling.purge,metrics.nightly,user.client-activity.rollup,user.review-prompt.evaluate,user.dormant.process,reminder.email.process,reminder.push.process,reminder.watchdog,feed.reindex)} by {name} < 1"
  message  = <<-EOT
    The scheduled task {{name.name}} has not executed. Every task here runs at least daily, so no execution at all means Beat, the worker, or the task's registration is broken rather than the work merely failing.

    Notify: @support@heliumedu.com
  EOT
  priority = 2

  include_tags        = true
  on_missing_data     = "show_and_notify_no_data"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    critical = 1
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
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
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 50
    critical = 60
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "api_slow_responses" {
  name     = "API Response Times Degraded"
  type     = "query alert"
  query    = "avg(last_1d):avg:platform.request.timing.95percentile{env:prod} > 3000"
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
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 2000
    critical = 3000
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "redis_needs_upgrade" {
  name     = "Redis Instance Needs Upgrade"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.elasticache.database_memory_usage_percentage{replication_group:helium-prod} > 70"
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
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 60
    critical = 70
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "api_5xx_alb_child" {
  name     = "API 5xx Error Spike - ALB (child)"
  type     = "query alert"
  query    = "sum(last_5m):(sum:aws.applicationelb.httpcode_elb_5xx{name:helium-prod}.as_count() + sum:aws.applicationelb.httpcode_target_5xx{name:helium-prod}.as_count()) > 5"
  message  = "ALB 5xx child monitor - see 'API 5xx Error Spike' composite monitor for alerts."
  priority = 3

  include_tags        = false
  on_missing_data     = "resolve"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 1
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "api_5xx_spike" {
  name              = "API 5xx Error Spike"
  type              = "composite"
  query             = "${datadog_monitor.server_error_spike.id} || ${datadog_monitor.api_5xx_alb_child.id}"
  renotify_interval = 1440
  message           = <<-EOT
    API 5xx error spike detected. Investigate:
    - App-level 500s: the platform may be experiencing errors (check Sentry)
    - ALB ELB 5xx: ALB-generated errors (502/503/504); ECS targets may be unhealthy or unreachable
    - ALB Target 5xx: backend returning 5xx as seen by the ALB

    Notify: @support@heliumedu.com
  EOT
  priority          = 2

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "frontend_5xx_spike" {
  name     = "Frontend 5xx Error Rate Elevated"
  type     = "query alert"
  query    = "avg(last_5m):sum:aws.cloudfront.5xx_error_rate{environment:prod}.weighted() > 5"
  message  = <<-EOT
    CloudFront 5xx error rate has exceeded {{ threshold }}% in the last 5 minutes. The frontend S3 origin may be unavailable or misconfigured.

    Notify: @support@heliumedu.com
  EOT
  priority = 2

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 1
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "ses_bounce_rate" {
  name     = "SES Bounce Rate Elevated"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.ses.reputation_bounce_rate{*} > 0.05"
  message  = <<-EOT
    SES account bounce rate has exceeded 5% over the last 24 hours. AWS begins reviewing accounts at 5% and may suspend sending at 10%.

    Investigate recent email sends for invalid addresses or unexpected bounce patterns.

    Notify: @support@heliumedu.com
  EOT
  priority = 2

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 0.03
    critical = 0.05
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "ses_complaint_rate" {
  name     = "SES Complaint Rate Elevated"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.ses.reputation_complaint_rate{*} > 0.003"
  message  = <<-EOT
    SES account complaint rate has exceeded 0.3% over the last 24 hours. AWS begins reviewing accounts at 0.1% and may suspend sending at 0.5%.

    Investigate recent email sends for unexpected complaint patterns. Do not suppress users based on complaints; investigate for bugs or unexpected send volume instead.

    Notify: @support@heliumedu.com
  EOT
  priority = 2

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    critical = 0.003
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "support_contact_abuse" {
  name     = "Support Contact Abuse Escalation"
  type     = "query alert"
  query    = "sum(last_1d):default_zero(sum:platform.action.support_contact.honeypot{env:prod}.as_count()) + default_zero(sum:platform.action.support_contact.throttled{env:prod}.as_count()) > 25"
  message  = <<-EOT
    Support contact honeypot and throttle signals have exceeded {{ threshold }} combined over the last 24 hours. Review submission sources and tighten controls if needed.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 10
    critical = 25
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
  renotify_interval   = 1440

  monitor_thresholds {
    warning  = 45
    critical = 55
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "client_4xx_anomaly" {
  name     = "Client 4xx Error Anomaly"
  type     = "query alert"
  query    = "avg(last_4h):anomalies(sum:platform.request{env:prod AND (status_code:400 OR status_code:404 OR status_code:422)}.as_count(), 'agile', 3) >= 1"
  message  = <<-EOT
    Client 4xx errors (400/404/422) are anomalously high versus the normal baseline. Slice platform.request by path and client_version to find the offending endpoint or release.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    critical = 1
  }

  monitor_threshold_windows {
    trigger_window  = "last_30m"
    recovery_window = "last_30m"
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "certificate_renewal_failed" {
  name     = "SSL Certificate Renewal Failed"
  type     = "query alert"
  query    = "min(last_1d):min:aws.certificatemanager.days_to_expiry{*} < 30"
  message  = <<-EOT
    An ACM certificate expires in under {{ threshold }} days. ACM auto-renews DNS-validated certificates starting at 60 days, so reaching this threshold means renewal is failing. The usual cause is a missing or altered `_<hash>` validation CNAME in Route53, which serves no traffic and so breaks nothing else until the certificate expires.

    Run `terraform plan` in the affected workspace to surface the drifted validation record and apply it. ACM retries renewal on its own once the record is restored.

    Notify: @support@heliumedu.com
  EOT
  priority = 3

  include_tags        = true
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 1440

  monitor_thresholds {
    critical = 30
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}
