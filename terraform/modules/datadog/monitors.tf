resource "datadog_monitor" "no_emails_sent" {
  name    = "No Emails Sent Today"
  type    = "query alert"
  query   = "sum(last_1d):sum:platform.action.email.sent{env:prod}.as_count() < 1"
  message = <<-EOT
    Daily emails have dropped to 0, which means even cluster tests aren't successfully triggering emails. The Helium platform and AWS SES service should be investigated.

    Notify: @alexdlaird@gmail.com
  EOT

  include_tags        = false
  on_missing_data     = "show_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 1
  }
}

resource "datadog_monitor" "no_texts_sent" {
  name    = "No Texts Sent Today"
  type    = "query alert"
  query   = "sum(last_1d):sum:platform.action.text.sent{env:prod}.as_count() < 1"
  message = <<-EOT
    Daily texts have dropped to 0, which means even cluster tests aren't successfully triggering texts. The Helium platform and Twilio service should be investigated.

    Notify: @alexdlaird@gmail.com
  EOT

  include_tags        = false
  on_missing_data     = "show_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 1
  }
}

resource "datadog_monitor" "token_api_down" {
  name    = "/token API (Login) May Be Down"
  type    = "query alert"
  query   = "sum(last_1d):sum:platform.request{env:prod, status_code:200, method:post, path:auth.token}.as_count() < 10"
  message = <<-EOT
    The API response 200 on /token is less than {{ threshold }} for the last 24 hours, meaning login may be down. This should be investigated.

    Notify: @alexdlaird@gmail.com
  EOT

  include_tags        = false
  on_missing_data     = "show_and_notify_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 10
  }
}

resource "datadog_monitor" "feed_reindex_time_exceeded" {
  name    = "Feed Reindex Time Exceeded Threshold"
  type    = "query alert"
  query   = "sum(last_1h):max:platform.task.timing.avg{env:prod, name:feed.reindex} / 1000 > 300"
  message = <<-EOT
    Reindex of Feeds in the cache exceeded the threshold of {{ threshold }} seconds.

    Notify: @alexdlaird@gmail.com
  EOT

  include_tags        = false
  on_missing_data     = "show_and_notify_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 300
  }
}

resource "datadog_monitor" "token_refresh_api_down" {
  name    = "/token/refresh API (Active Sessions) May Be Down"
  type    = "query alert"
  query   = "sum(last_4h):sum:platform.request{env:prod, status_code:200, method:post, path:auth.token.refresh}.as_count() < 5"
  message = <<-EOT
    The API response 200 on /token/refresh is less than {{ threshold }} for the last 8 hours, meaning the site may be down. This should be investigated.

    Notify: @alexdlaird@gmail.com
  EOT

  include_tags        = false
  on_missing_data     = "show_and_notify_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 5
  }
}

resource "datadog_monitor" "no_push_notifications_sent" {
  name    = "No Push Notifications Sent Today"
  type    = "query alert"
  query   = "sum(last_1d):sum:platform.action.push.sent{env:prod}.as_count() < 1"
  message = <<-EOT
    Daily push notifications have dropped to 0, which means even cluster tests aren't successfully triggering pushes. The Helium platform and Firebase service should be investigated.

    Notify: @alexdlaird@gmail.com
  EOT

  include_tags        = false
  on_missing_data     = "show_no_data"
  require_full_window = false

  monitor_thresholds {
    critical = 1
  }
}
