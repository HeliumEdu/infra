resource "datadog_monitor" "low_email_traffic" {
  name    = "Low Email Traffic"
  type    = "query alert"
  query   = "sum(last_4h):sum:platform.action.email.sent{env:prod}.as_count() < 5"
  message = <<-EOT
    Emails sent are below {{ threshold }} in the last 4 hours. The Helium platform or AWS SES service may need investigation.
  EOT

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "token_api_low_traffic" {
  name    = "Low Login Traffic (/token)"
  type    = "query alert"
  query   = "sum(last_4h):sum:platform.request{env:prod, status_code:200, method:post, path:auth.token}.as_count() < 5"
  message = <<-EOT
    Successful logins on /token are below {{ threshold }} in the last 4 hours.
  EOT

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "feed_reindex_time_exceeded" {
  name    = "Feed Reindex Time Exceeded Threshold"
  type    = "query alert"
  query   = "sum(last_1h):max:platform.task.timing.avg{env:prod, name:feed.reindex} / 1000 > 300"
  message = <<-EOT
    Reindex of Feeds in the cache exceeded {{ threshold }} seconds.

    Notify: @support@heliumedu.com
  EOT

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 120
    critical = 300
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "token_refresh_api_low_traffic" {
  name    = "Low Session Refresh Traffic (/token/refresh)"
  type    = "query alert"
  query   = "sum(last_4h):sum:platform.request{env:prod, status_code:200, method:post, path:auth.token.refresh}.as_count() < 5"
  message = <<-EOT
    Successful session refreshes on /token/refresh are below {{ threshold }} in the last 4 hours.
  EOT

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "low_push_notification_traffic" {
  name    = "Low Push Notification Traffic"
  type    = "query alert"
  query   = "sum(last_4h):sum:platform.action.push.sent{env:prod}.as_count() < 5"
  message = <<-EOT
    Push notifications sent are below {{ threshold }} in the last 4 hours. The Helium platform or Firebase service may need investigation.
  EOT

  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false

  monitor_thresholds {
    warning  = 10
    critical = 5
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "email_delivery_failures" {
  name    = "Email Delivery Failure Spike"
  type    = "query alert"
  query   = "sum(last_1h):sum:platform.action.email.failed{env:prod}.as_count() > 5"
  message = <<-EOT
    More than {{ threshold }} email delivery failures detected. AWS SES or the email sending service should be investigated.

    Notify: @support@heliumedu.com
  EOT

  include_tags        = false
  on_missing_data     = "show_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "push_delivery_failures" {
  name    = "Push Notification Delivery Failure Spike"
  type    = "query alert"
  query   = "sum(last_1h):sum:platform.action.push.failed{env:prod}.as_count() > 5"
  message = <<-EOT
    More than {{ threshold }} push notification delivery failures detected. Firebase Cloud Messaging should be investigated.

    Notify: @support@heliumedu.com
  EOT

  include_tags        = false
  on_missing_data     = "show_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "server_error_spike" {
  name    = "500 Error Spike"
  type    = "query alert"
  query   = "sum(last_5m):sum:platform.request{env:prod, status_code:500}.as_count() > 10"
  message = <<-EOT
    More than {{ threshold }} 500 errors in the last 5 minutes. The platform may be experiencing issues.

    Notify: @support@heliumedu.com
  EOT

  include_tags        = false
  on_missing_data     = "show_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 10
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "calendar_sync_failures" {
  name    = "Calendar Sync Failure Spike"
  type    = "query alert"
  query   = "sum(last_1h):sum:platform.feed.ical.failed{env:prod}.as_count() > 5"
  message = <<-EOT
    More than {{ threshold }} calendar sync failures detected. iCal feed fetching should be investigated.

    Notify: @support@heliumedu.com
  EOT

  include_tags        = false
  on_missing_data     = "show_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "firebase_oauth_failures" {
  name    = "Firebase/OAuth Failure Spike"
  type    = "query alert"
  query   = "sum(last_1h):sum:platform.external.firebase.failed{env:prod}.as_count() > 5"
  message = <<-EOT
    More than {{ threshold }} Firebase/OAuth failures detected. OAuth integration should be investigated.

    Notify: @support@heliumedu.com
  EOT

  include_tags        = false
  on_missing_data     = "show_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform"]
}

resource "datadog_monitor" "task_failures" {
  name    = "Background Task Failure Spike"
  type    = "query alert"
  query   = "sum(last_1h):sum:platform.task.failed{env:prod}.as_count() > 5"
  message = <<-EOT
    More than {{ threshold }} background task failures detected. Celery workers and task processing should be investigated.

    Notify: @support@heliumedu.com
  EOT

  include_tags        = false
  on_missing_data     = "show_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }

  tags = ["managed_by:terraform"]
}
