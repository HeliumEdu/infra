resource "datadog_monitor" "low_email_traffic" {
  name     = "${local.notify.info.label} Low Email Traffic"
  type     = "query alert"
  query    = "sum(last_24h):sum:platform.action.email.sent{env:prod}.as_count() < 5"
  message  = <<-EOT
    Emails sent are below {{ warn_threshold }} (warning) / {{ threshold }} (critical) in the last 24 hours. The Helium platform or AWS SES service may need investigation.

    ${local.notify.info.message}
  EOT
  priority = local.notify.info.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.info.renotify_interval
  renotify_occurrences = local.notify.info.renotify_occurrences
  renotify_statuses    = local.notify.info.renotify_statuses
  escalation_message   = local.notify.info.escalation_message

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "auth_low_traffic" {
  name     = "${local.notify.info.label} Low Auth Traffic - {{path.name}}"
  type     = "query alert"
  query    = "sum(last_24h):sum:platform.request{env:prod AND status_code:200 AND method:post AND path IN (auth.token,auth.token.refresh)} by {path}.as_count() < 5"
  message  = <<-EOT
    Successful requests on {{path.name}} are below {{ warn_threshold }} (warning) / {{ threshold }} (critical) in the last 24 hours. No data means none succeeded at all.

    ${local.notify.info.message}
  EOT
  priority = local.notify.info.priority

  include_tags         = false
  on_missing_data      = "show_and_notify_no_data"
  require_full_window  = false
  renotify_interval    = local.notify.info.renotify_interval
  renotify_occurrences = local.notify.info.renotify_occurrences
  renotify_statuses    = local.notify.info.renotify_statuses
  escalation_message   = local.notify.info.escalation_message

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "low_push_notification_traffic" {
  name     = "${local.notify.info.label} Low Push Notification Traffic"
  type     = "query alert"
  query    = "sum(last_24h):sum:platform.action.push.sent{env:prod}.as_count() < 1"
  message  = <<-EOT
    Push notifications sent are below {{ warn_threshold }} (warning) / {{ threshold }} (critical) in the last 24 hours. The Helium platform or Firebase service may need investigation.

    ${local.notify.info.message}
  EOT
  priority = local.notify.info.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.info.renotify_interval
  renotify_occurrences = local.notify.info.renotify_occurrences
  renotify_statuses    = local.notify.info.renotify_statuses
  escalation_message   = local.notify.info.escalation_message

  monitor_thresholds {
    warning  = 5
    critical = 1
  }

  tags = ["managed_by:terraform", "alert_type:informational"]
}

resource "datadog_monitor" "email_delivery_failures" {
  name     = "${local.notify.degraded.label} Email Delivery Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.action.email.failed{env:prod}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} email delivery failures detected in the last hour. AWS SES or the email sending service should be investigated.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "push_delivery_failures" {
  name     = "${local.notify.degraded.label} Push Notification Delivery Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.action.push.failed{env:prod,!reason:unregistered}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} push notification delivery failures detected in the last hour, excluding tokens that were simply retired. Firebase Cloud Messaging should be investigated.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

locals {
  # Added to every 5xx-rate denominator so a handful of requests in a quiet window cannot spike the
  # rate; at real traffic volumes it is negligible and the result converges to the true error rate.
  error_rate_smoothing_requests = 25
  # The same allowance spread across a 5-minute window, for rates evaluated one minute at a time.
  error_rate_smoothing_requests_per_minute = 5
  # A smaller allowance for the hard-down threshold, so a total outage still crosses it at overnight traffic.
  hard_down_smoothing_requests_per_minute = 1

  # Per-minute 5xx percentages, so min(last_Nm) means every minute of the window failed at that rate.
  alb_5xx_rate_per_minute        = "(default_zero(sum:aws.applicationelb.httpcode_elb_5xx{name:helium-prod-api}.rollup(sum, 60)) + default_zero(sum:aws.applicationelb.httpcode_target_5xx{name:helium-prod-api}.rollup(sum, 60))) / (default_zero(sum:aws.applicationelb.request_count{name:helium-prod-api}.rollup(sum, 60)) + %d) * 100"
  cloudfront_5xx_rate_per_minute = "default_zero(sum:aws.cloudfront.requests{%[1]s}%[2]s.rollup(sum, 60) * avg:aws.cloudfront.5xx_error_rate{%[1]s}%[2]s.rollup(avg, 60) / 100) / (default_zero(sum:aws.cloudfront.requests{%[1]s}%[2]s.rollup(sum, 60)) + %[3]d) * 100"
}

resource "datadog_monitor" "server_error_spike" {
  name     = "${local.notify.down.label} API 5xx - App"
  type     = "query alert"
  query    = "sum(last_5m):default_zero(sum:platform.request{env:prod, status_code:5*}.as_count()) / (sum:platform.request{env:prod}.as_count() + ${local.error_rate_smoothing_requests}) * 100 > 5"
  message  = <<-EOT
    The API itself returned 5xx on more than {{ threshold }}% of requests over the last 5 minutes. These come from our code, not AWS: check Sentry, and whether a release just went out.

    ${local.notify.down.message}
  EOT
  priority = local.notify.down.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.down.renotify_interval
  renotify_occurrences = local.notify.down.renotify_occurrences
  renotify_statuses    = local.notify.down.renotify_statuses
  escalation_message   = local.notify.down.escalation_message

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "calendar_sync_failures" {
  name     = "${local.notify.degraded.label} Calendar Sync Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.external_calendar.fetch.failed{env:prod}.as_count() > 15"
  message  = <<-EOT
    More than {{ threshold }} calendar sync failures detected in the last hour. iCal feed fetching should be investigated.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 15
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "firebase_oauth_failures" {
  name     = "${local.notify.degraded.label} Firebase/OAuth Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.external.firebase.failed{env:prod}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} Firebase/OAuth failures detected in the last hour. OAuth integration should be investigated.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "task_failures" {
  name     = "${local.notify.degraded.label} Background Task Failure Spike"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.task.failed{env:prod} by {name}.as_count() > 5"
  message  = <<-EOT
    More than {{ threshold }} failures of the background task {{name.name}} in the last hour. Celery workers and task processing should be investigated.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = true
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "task_lost" {
  name     = "${local.notify.degraded.label} Background Task Lost - {{name.name}}"
  type     = "query alert"
  query    = "sum(last_1h):sum:platform.task.lost{env:prod} by {name}.as_count() > 0"
  message  = <<-EOT
    The background task {{name.name}} died without finishing ({{ value }} in the last hour). The worker process running it was killed, most often for running out of memory, so the task's work (a reminder, an email, a sync) never happened.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = true
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 0
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "worker_metrics_missing" {
  name     = "${local.notify.down.label} Worker Metrics Missing"
  type     = "query alert"
  query    = "sum(last_30m):sum:platform.task.timing.count{env:prod AND name:metrics.queue-depth}.as_count() < 1"
  message  = <<-EOT
    The worker has reported no metrics for 30 minutes, though it reports one every minute. Either the worker is down or its metrics are no longer reaching Datadog, and task failures would go unreported meanwhile.

    ${local.notify.down.message}
  EOT
  priority = local.notify.down.priority

  include_tags         = false
  on_missing_data      = "show_and_notify_no_data"
  require_full_window  = false
  renotify_interval    = local.notify.down.renotify_interval
  renotify_occurrences = local.notify.down.renotify_occurrences
  renotify_statuses    = local.notify.down.renotify_statuses
  escalation_message   = local.notify.down.escalation_message

  monitor_thresholds {
    critical = 1
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "scheduled_task_not_running" {
  name     = "${local.notify.down.label} Scheduled Task Not Running"
  type     = "query alert"
  query    = "sum(last_2d):sum:platform.task.timing.count{env:prod AND name IN (token.refresh.purge,push.token.purge,metrics.queue-depth,user.dangling.purge,metrics.nightly,user.client-activity.rollup,user.review-prompt.evaluate,user.dormant.process,reminder.email.process,reminder.push.process,reminder.watchdog,external_calendar.reindex)} by {name}.as_count() < 1"
  message  = <<-EOT
    The scheduled task {{name.name}} has not executed. Every task here runs at least daily, so no execution at all means Beat, the worker, or the task's registration is broken rather than the work merely failing.

    ${local.notify.down.message}
  EOT
  priority = local.notify.down.priority

  include_tags         = true
  on_missing_data      = "show_and_notify_no_data"
  require_full_window  = false
  renotify_interval    = local.notify.down.renotify_interval
  renotify_occurrences = local.notify.down.renotify_occurrences
  renotify_statuses    = local.notify.down.renotify_statuses
  escalation_message   = local.notify.down.escalation_message

  monitor_thresholds {
    critical = 1
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "api_slow_responses" {
  name     = "${local.notify.degraded.label} API Response Times Degraded - {{path.name}}"
  type     = "query alert"
  query    = "avg(last_1d):median_9(avg:platform.request.timing.avg{env:prod, !path:importexport.*, !path:api.common.support.contact, !path:auth.user.delete, !path:auth.user.delete.*, !path:auth.user.oauthproviders, !path:auth.user.oauthproviders.*, !path:planner.events.delete.all, !path:auth.token, !path:auth.user.register, !path:auth.user.forgot.confirm} by {path}.rollup(avg, 3600)) > 500"
  message  = <<-EOT
    Response times for {{path.name}} have held above {{ warn_threshold }}ms (warning) / {{ threshold }}ms (critical) over the last 24 hours, outliers excluded.

    Sustained slow responses indicate a configuration or optimization issue:
    - Database queries need optimization (check Sentry for N+1, slow queries)
    - API tasks may be undersized
    - Missing database indexes

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 250
    critical = 500
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "importexport_slow_responses" {
  name     = "${local.notify.degraded.label} Import/Export Response Times Degraded - {{path.name}}"
  type     = "query alert"
  query    = "avg(last_1d):median_9(avg:platform.request.timing.avg{env:prod, path:importexport.*} by {path}.rollup(avg, 3600)) > 10000"
  message  = <<-EOT
    Response times for {{path.name}} have held above {{ warn_threshold }}ms (warning) / {{ threshold }}ms (critical) over the last 24 hours, outliers excluded.

    Import and export run synchronously, so this is user-facing wait time:
    - Check for N+1 growth in the import/export serializers as models gain fields
    - Confirm example schedule seeding has not grown (resources/example_schedule.json)
    - Large user datasets may need the work moved to a background task

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 6000
    critical = 10000
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "auth_slow_responses" {
  name     = "${local.notify.degraded.label} Auth Response Times Degraded - {{path.name}}"
  type     = "query alert"
  query    = "avg(last_1d):median_9(avg:platform.request.timing.avg{env:prod AND path IN (auth.token,auth.user.register,auth.user.forgot.confirm)} by {path}.rollup(avg, 3600)) > 1500"
  message  = <<-EOT
    Response times for {{path.name}} have held above {{ warn_threshold }}ms (warning) / {{ threshold }}ms (critical) over the last 24 hours, outliers excluded.

    These paths hash a password; above this threshold, work has been added on top of that baseline:
    - Work made synchronous that belongs in a background task (email, analytics, provisioning)
    - N+1 growth in the user or settings serializers
    - API tasks may be undersized

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 800
    critical = 1500
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "auth_hashing_weakened" {
  name     = "${local.notify.degraded.label} Auth Password Hashing Unexpectedly Fast"
  type     = "query alert"
  query    = "avg(last_1d):median_9(avg:platform.request.timing.avg{env:prod, path:auth.token}.rollup(avg, 3600)) < 200"
  message  = <<-EOT
    Response times for logins on /token have held below {{ warn_threshold }}ms (warning) / {{ threshold }}ms (critical) over the last 24 hours, outliers excluded.

    Responses this fast mean password verification is not running as configured:
    - A faster hasher, or a lower iteration count, at the front of PASSWORD_HASHERS
    - Authentication short-circuiting before check_password
    - Faster underlying hardware, which needs the iteration count raised to compensate

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "resolve"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 300
    critical = 200
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "task_duration_degraded" {
  name     = "${local.notify.degraded.label} Background Task Duration Degraded - {{name.name}}"
  type     = "query alert"
  query    = "avg(last_1w):median_9(avg:platform.task.timing.avg{env:prod, !name:external_calendar.reindex, !name:reminder.email.process, !name:reminder.push.process, !name:user.dangling.purge, !name:user.dormant.process, !name:metrics.nightly} by {name}.rollup(avg, 3600)) > 60000"
  message  = <<-EOT
    Task {{name.name}} has held above {{ warn_threshold }}ms (warning) / {{ threshold }}ms (critical) of execution time over the last week, outliers excluded.

    Sustained slow execution indicates a configuration or optimization issue:
    - Check for N+1 growth as the task's underlying models gain fields or relations
    - Per-user tasks scale with user count, per-row tasks with data volume
    - Sustained growth may mean the task needs batching or a schedule change

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 20000
    critical = 60000
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "reminder_dispatch_saturation" {
  name     = "${local.notify.degraded.label} Reminder Dispatch Approaching Its Interval - {{name.name}}"
  type     = "query alert"
  query    = "avg(last_1h):avg:platform.task.timing.avg{env:prod AND name IN (reminder.email.process,reminder.push.process)} by {name} > 45000"
  message  = <<-EOT
    The mean runtime for {{name.name}} has been above {{ warn_threshold }}ms (warning) / {{ threshold }}ms (critical) over the last hour, against a 60 second dispatch interval.

    A fan-out approaching its own interval risks overlapping ticks and late reminders:
    - Reminders due per minute may have outgrown one-at-a-time dispatch
    - Broker latency may be elevated (cross-check high priority queue wait time)
    - Dispatch may need batching rather than an apply_async per reminder

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 30000
    critical = 45000
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "api_5xx_alb_child" {
  name     = "${local.notify.degraded.label} API 5xx - ALB"
  type     = "query alert"
  query    = "min(last_15m):${format(local.alb_5xx_rate_per_minute, local.error_rate_smoothing_requests_per_minute)} > 5"
  message  = <<-EOT
    At least {{ threshold }}% of API requests failed at the load balancer every minute for 15 minutes, as ALB-generated 502/503/504 or 5xx from the targets. Brief AWS blips never last this long; sustained errors mean ECS targets are unhealthy or unreachable. AWS reports these about 15 minutes late.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  evaluation_delay     = 900
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "api_5xx_alb_down" {
  name     = "${local.notify.down.label} API 5xx - ALB"
  type     = "query alert"
  query    = "min(last_3m):${format(local.alb_5xx_rate_per_minute, local.hard_down_smoothing_requests_per_minute)} > 50"
  message  = <<-EOT
    At least {{ threshold }}% of API requests failed at the load balancer every minute for 3 minutes, so the API is effectively down, whether the cause is our tasks or AWS. AWS reports these about 15 minutes late.

    ${local.notify.down.message}
  EOT
  priority = local.notify.down.priority

  include_tags         = false
  on_missing_data      = "default"
  evaluation_delay     = 900
  require_full_window  = false
  renotify_interval    = local.notify.down.renotify_interval
  renotify_occurrences = local.notify.down.renotify_occurrences
  renotify_statuses    = local.notify.down.renotify_statuses
  escalation_message   = local.notify.down.escalation_message

  monitor_thresholds {
    critical = 50
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "api_5xx_cloudfront_child" {
  name     = "${local.notify.degraded.label} API 5xx - CloudFront"
  type     = "query alert"
  query    = "min(last_15m):${format(local.cloudfront_5xx_rate_per_minute, "environment:prod,role:api", "", local.error_rate_smoothing_requests_per_minute)} > 5"
  message  = <<-EOT
    At least {{ threshold }}% of API requests failed at CloudFront every minute for 15 minutes, including CloudFront unable to reach the internal ALB. Brief AWS blips never last this long. AWS reports these about 15 minutes late.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  evaluation_delay     = 900
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "api_5xx_cloudfront_down" {
  name     = "${local.notify.down.label} API 5xx - CloudFront"
  type     = "query alert"
  query    = "min(last_3m):${format(local.cloudfront_5xx_rate_per_minute, "environment:prod,role:api", "", local.hard_down_smoothing_requests_per_minute)} > 50"
  message  = <<-EOT
    At least {{ threshold }}% of API requests failed at CloudFront every minute for 3 minutes, so the API is effectively down for users, whether the cause is ours or AWS. AWS reports these about 15 minutes late.

    ${local.notify.down.message}
  EOT
  priority = local.notify.down.priority

  include_tags         = false
  on_missing_data      = "default"
  evaluation_delay     = 900
  require_full_window  = false
  renotify_interval    = local.notify.down.renotify_interval
  renotify_occurrences = local.notify.down.renotify_occurrences
  renotify_statuses    = local.notify.down.renotify_statuses
  escalation_message   = local.notify.down.escalation_message

  monitor_thresholds {
    critical = 50
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "connector_5xx_spike" {
  name     = "${local.notify.degraded.label} Connector 5xx"
  type     = "query alert"
  query    = "min(last_15m):${format(local.cloudfront_5xx_rate_per_minute, "environment:prod,role:connector", "", local.error_rate_smoothing_requests_per_minute)} > 5"
  message  = <<-EOT
    At least {{ threshold }}% of connector (mcp.heliumedu.com) requests failed every minute for 15 minutes. Check the helium-prod-connector Lambda logs in CloudWatch, and the API 5xx monitors, since the connector answers 500 when it can't verify a token. AWS reports these about 15 minutes late.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  evaluation_delay     = 900
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "connector_5xx_down" {
  name     = "${local.notify.down.label} Connector 5xx"
  type     = "query alert"
  query    = "min(last_3m):${format(local.cloudfront_5xx_rate_per_minute, "environment:prod,role:connector", "", local.hard_down_smoothing_requests_per_minute)} > 50"
  message  = <<-EOT
    At least {{ threshold }}% of connector (mcp.heliumedu.com) requests failed every minute for 3 minutes, so the connector is effectively down. Check the helium-prod-connector Lambda logs in CloudWatch, and the API 5xx monitors. AWS reports these about 15 minutes late.

    ${local.notify.down.message}
  EOT
  priority = local.notify.down.priority

  include_tags         = false
  on_missing_data      = "default"
  evaluation_delay     = 900
  require_full_window  = false
  renotify_interval    = local.notify.down.renotify_interval
  renotify_occurrences = local.notify.down.renotify_occurrences
  renotify_statuses    = local.notify.down.renotify_statuses
  escalation_message   = local.notify.down.escalation_message

  monitor_thresholds {
    critical = 50
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "frontend_5xx_spike" {
  name     = "${local.notify.degraded.label} Frontend 5xx - {{distributionid.name}}"
  type     = "query alert"
  query    = "min(last_15m):${format(local.cloudfront_5xx_rate_per_minute, "environment:prod,!role:api,!role:connector", " by {distributionid}", local.error_rate_smoothing_requests_per_minute)} > 5"
  message  = <<-EOT
    At least {{ threshold }}% of requests to CloudFront distribution {{distributionid.name}} failed every minute for 15 minutes. The frontend S3 origin may be unavailable or misconfigured. AWS reports these about 15 minutes late.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  evaluation_delay     = 900
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "frontend_5xx_down" {
  name     = "${local.notify.down.label} Frontend 5xx - {{distributionid.name}}"
  type     = "query alert"
  query    = "min(last_3m):${format(local.cloudfront_5xx_rate_per_minute, "environment:prod,!role:api,!role:connector", " by {distributionid}", local.hard_down_smoothing_requests_per_minute)} > 50"
  message  = <<-EOT
    At least {{ threshold }}% of requests to CloudFront distribution {{distributionid.name}} failed every minute for 3 minutes, so the site is effectively down. The frontend S3 origin may be unavailable or misconfigured. AWS reports these about 15 minutes late.

    ${local.notify.down.message}
  EOT
  priority = local.notify.down.priority

  include_tags         = false
  on_missing_data      = "default"
  evaluation_delay     = 900
  require_full_window  = false
  renotify_interval    = local.notify.down.renotify_interval
  renotify_occurrences = local.notify.down.renotify_occurrences
  renotify_statuses    = local.notify.down.renotify_statuses
  escalation_message   = local.notify.down.escalation_message

  monitor_thresholds {
    critical = 50
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "ses_bounce_rate" {
  name     = "${local.notify.degraded.label} SES Bounce Rate Elevated"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.ses.reputation_bounce_rate{*} > 0.05"
  message  = <<-EOT
    SES account bounce rate has exceeded 3% (warning) / 5% (critical) over the last 24 hours. AWS begins reviewing accounts at 5% and may suspend sending at 10%.

    Investigate recent email sends for invalid addresses or unexpected bounce patterns.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 0.03
    critical = 0.05
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "ses_complaint_rate" {
  name     = "${local.notify.degraded.label} SES Complaint Rate Elevated"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.ses.reputation_complaint_rate{*} > 0.003"
  message  = <<-EOT
    SES account complaint rate has exceeded 0.3% over the last 24 hours. AWS begins reviewing accounts at 0.1% and may suspend sending at 0.5%.

    Investigate recent email sends for unexpected complaint patterns. Do not suppress users based on complaints; investigate for bugs or unexpected send volume instead.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 0.003
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "support_contact_abuse" {
  name     = "${local.notify.info.label} Support Contact Abuse Escalation"
  type     = "query alert"
  query    = "sum(last_1d):default_zero(sum:platform.action.support_contact.honeypot{env:prod}.as_count()) + default_zero(sum:platform.action.support_contact.throttled{env:prod}.as_count()) > 25"
  message  = <<-EOT
    Support contact honeypot and throttle signals have exceeded {{ warn_threshold }} (warning) / {{ threshold }} (critical) combined over the last 24 hours. Review submission sources and tighten controls if needed.

    ${local.notify.info.message}
  EOT
  priority = local.notify.info.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.info.renotify_interval
  renotify_occurrences = local.notify.info.renotify_occurrences
  renotify_statuses    = local.notify.info.renotify_statuses
  escalation_message   = local.notify.info.escalation_message

  monitor_thresholds {
    warning  = 10
    critical = 25
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

resource "datadog_monitor" "client_4xx_anomaly" {
  name     = "${local.notify.info.label} Client 4xx Error Anomaly"
  type     = "query alert"
  query    = "avg(last_4h):anomalies(sum:platform.request{env:prod AND (status_code:400 OR status_code:404 OR status_code:422)}.as_count(), 'agile', 3) >= 1"
  message  = <<-EOT
    Client 4xx errors (400/404/422) are anomalously high versus the normal baseline. Slice platform.request by path, client, and client_os to find the offending endpoint or client, then check platform.client_version for a recent release.

    ${local.notify.info.message}
  EOT
  priority = local.notify.info.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.info.renotify_interval
  renotify_occurrences = local.notify.info.renotify_occurrences
  renotify_statuses    = local.notify.info.renotify_statuses
  escalation_message   = local.notify.info.escalation_message

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
  name     = "${local.notify.degraded.label} SSL Certificate Renewal Failed"
  type     = "query alert"
  query    = "min(last_1d):min:aws.certificatemanager.days_to_expiry{*} < 30"
  message  = <<-EOT
    An ACM certificate expires in under {{ threshold }} days. ACM auto-renews DNS-validated certificates starting at 60 days, so reaching this threshold means renewal is failing. The usual cause is a missing or altered `_<hash>` validation CNAME in Route53, which serves no traffic and so breaks nothing else until the certificate expires.

    Run `terraform plan` in the affected workspace to surface the drifted validation record and apply it. ACM retries renewal on its own once the record is restored.

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = true
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    critical = 30
  }

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "high_priority_queue_wait" {
  name    = "${local.notify.degraded.label} High Priority Task Queue Wait Time Elevated"
  type    = "query alert"
  message = <<-EOT
    High priority tasks are waiting in the queue for extended periods (p95 above {{ warn_threshold }} ms for warning, {{ threshold }} ms for critical, over the last hour).

    This indicates the worker may be overwhelmed with low-priority tasks,
    and it may be time to split into separate high/low priority queues.

    Current p95 queue wait time: {{ value }} ms

    ${local.notify.degraded.message}
  EOT

  query = "avg(last_1h):avg:platform.task.queue_time.95percentile{env:prod, priority:high} > 60000"

  monitor_thresholds {
    critical = 60000
    warning  = 45000
  }

  priority             = local.notify.degraded.priority
  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  tags = ["managed_by:terraform", "alert_type:config"]
}

resource "datadog_monitor" "canary_failing" {
  name     = "${local.notify.down.label} Canary Tests Failing"
  type     = "query alert"
  query    = "min(last_2h):min:helium.canary.failed{env:prod} >= 1"
  message  = <<-EOT
    Every canary run in the last two hours failed, each after a retry. Check the failed Canary Tests runs in the frontend repo; screenshots of each failure are attached as artifacts. No data means the canary itself stopped running.

    ${local.notify.down.message}
  EOT
  priority = local.notify.down.priority

  include_tags         = false
  on_missing_data      = "show_and_notify_no_data"
  require_full_window  = false
  renotify_interval    = local.notify.down.renotify_interval
  renotify_occurrences = local.notify.down.renotify_occurrences
  renotify_statuses    = local.notify.down.renotify_statuses
  escalation_message   = local.notify.down.escalation_message

  monitor_thresholds {
    critical = 1
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}

# Capacity: one monitor per finite resource, each naming the setting that raises its ceiling. Limits
# are read from the live prod instances, so they update on the next apply of this stack after a resize.

data "aws_db_instance" "prod" {
  db_instance_identifier = "helium-prod"
}

data "aws_ec2_instance_type" "prod_db" {
  instance_type = trimprefix(data.aws_db_instance.prod.db_instance_class, "db.")
}

locals {
  # MySQL's default max_connections is DBInstanceClassMemory / 12582880. RDS reserves some memory
  # before computing it, so the instance's full memory yields a slight overestimate.
  rds_max_connections_estimate = floor(data.aws_ec2_instance_type.prod_db.memory_size * 1048576 / 12582880)
  rds_allocated_storage_bytes  = data.aws_db_instance.prod.allocated_storage * 1073741824
}

resource "datadog_monitor" "ecs_cpu" {
  name     = "${local.notify.degraded.label} Capacity - ECS CPU - {{servicename.name}}"
  type     = "query alert"
  query    = "avg(last_1h):avg:aws.ecs.cpuutilization{clustername:helium_prod} by {servicename} > 90"
  message  = <<-EOT
    {{servicename.name}} CPU has averaged above {{ warn_threshold }}% (warning) / {{ threshold }}% (critical) for the last hour.

    Autoscaling adds tasks above 70%, so CPU only holds here when the service is at its max task count or cannot scale:
    - Raise platform_host_max / platform_worker_max in the prod environment
    - Increase task CPU in the ECS task definition
    - For the worker, check for a runaway or newly expensive task

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 80
    critical = 90
  }

  tags = ["managed_by:terraform", "alert_type:capacity"]
}

resource "datadog_monitor" "ecs_memory" {
  name     = "${local.notify.degraded.label} Capacity - ECS Memory - {{servicename.name}}"
  type     = "query alert"
  query    = "avg(last_1h):avg:aws.ecs.memory_utilization{clustername:helium_prod} by {servicename} > 95"
  message  = <<-EOT
    {{servicename.name}} memory has averaged above {{ warn_threshold }}% (warning) / {{ threshold }}% (critical) for the last hour. Tasks reaching 100% are killed and replaced, dropping in-flight work.

    - Increase task memory in the ECS task definition
    - Lower GUNICORN_WORKERS / GUNICORN_THREADS (API) or CELERY_CONCURRENCY (worker)
    - Check for a leak: memory that keeps climbing with task uptime rather than with traffic

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 85
    critical = 95
  }

  tags = ["managed_by:terraform", "alert_type:capacity"]
}

resource "datadog_monitor" "rds_cpu" {
  name     = "${local.notify.degraded.label} Capacity - RDS CPU"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.rds.cpuutilization{dbinstanceidentifier:${data.aws_db_instance.prod.db_instance_identifier}} > 60"
  message  = <<-EOT
    RDS CPU has averaged above {{ warn_threshold }}% (warning) / {{ threshold }}% (critical) for the last 24 hours on ${data.aws_db_instance.prod.db_instance_class}.

    - Check Sentry and Performance Insights for slow or N+1 queries
    - Raise db_instance_size in the prod environment

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 40
    critical = 60
  }

  tags = ["managed_by:terraform", "alert_type:capacity"]
}

resource "datadog_monitor" "rds_connections" {
  name     = "${local.notify.degraded.label} Capacity - RDS Connections"
  type     = "query alert"
  query    = "max(last_1h):max:aws.rds.database_connections{dbinstanceidentifier:${data.aws_db_instance.prod.db_instance_identifier}} > ${floor(local.rds_max_connections_estimate * 0.75)}"
  message  = <<-EOT
    RDS connections have peaked above {{ warn_threshold }} (warning) / {{ threshold }} (critical) in the last hour, against an estimated limit of ${local.rds_max_connections_estimate} for ${data.aws_db_instance.prod.db_instance_class}.

    Each Gunicorn thread holds a persistent connection (CONN_MAX_AGE), so connections grow with API task count:
    - Lower platform_host_max, or GUNICORN_WORKERS / GUNICORN_THREADS
    - Check for connection leaks in application code
    - Raise db_instance_size in the prod environment

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = floor(local.rds_max_connections_estimate * 0.6)
    critical = floor(local.rds_max_connections_estimate * 0.75)
  }

  tags = ["managed_by:terraform", "alert_type:capacity"]
}

resource "datadog_monitor" "rds_storage" {
  name     = "${local.notify.degraded.label} Capacity - RDS Storage"
  type     = "query alert"
  query    = "min(last_1h):min:aws.rds.free_storage_space{dbinstanceidentifier:${data.aws_db_instance.prod.db_instance_identifier}} < ${floor(local.rds_allocated_storage_bytes * 0.1)}"
  message  = <<-EOT
    RDS free storage is below 20% (warning) / 10% (critical) of its ${data.aws_db_instance.prod.allocated_storage} GiB allocation. The instance goes read-only when it runs out.

    - Raise the RDS allocated storage
    - Check for runaway table growth

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "show_and_notify_no_data"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = floor(local.rds_allocated_storage_bytes * 0.2)
    critical = floor(local.rds_allocated_storage_bytes * 0.1)
  }

  tags = ["managed_by:terraform", "alert_type:capacity"]
}

resource "datadog_monitor" "redis_memory" {
  name     = "${local.notify.degraded.label} Capacity - Redis Memory"
  type     = "query alert"
  query    = "avg(last_1d):avg:aws.elasticache.database_memory_usage_percentage{replication_group:helium-prod} > 70"
  message  = <<-EOT
    Redis memory utilization has averaged above {{ warn_threshold }}% (warning) / {{ threshold }}% (critical) for the last 24 hours.

    - Review cache TTL settings (items not expiring)
    - Check for Celery queue backlog
    - Raise cache_instance_size in the prod environment

    ${local.notify.degraded.message}
  EOT
  priority = local.notify.degraded.priority

  include_tags         = false
  on_missing_data      = "default"
  require_full_window  = false
  renotify_interval    = local.notify.degraded.renotify_interval
  renotify_occurrences = local.notify.degraded.renotify_occurrences
  renotify_statuses    = local.notify.degraded.renotify_statuses
  escalation_message   = local.notify.degraded.escalation_message

  monitor_thresholds {
    warning  = 60
    critical = 70
  }

  tags = ["managed_by:terraform", "alert_type:capacity"]
}

