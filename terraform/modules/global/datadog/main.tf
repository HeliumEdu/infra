resource "datadog_dashboard" "helium_heads_up" {
  title       = "Helium Heads Up"
  description = "Managed by Terraform"
  layout_type = "ordered"
  reflow_type = "auto"

  template_variable {
    name     = "env"
    prefix   = "env"
    defaults = ["prod"]
  }
  template_variable {
    name     = "user_agent"
    prefix   = "user_agent"
    defaults = ["*"]
  }
  template_variable {
    name     = "authenticated"
    prefix   = "authenticated"
    defaults = ["*"]
  }
  template_variable {
    name     = "version"
    prefix   = "version"
    defaults = ["*"]
  }
  template_variable {
    name     = "staff"
    prefix   = "staff"
    defaults = ["false"]
  }

  # Quick Stats Group
  widget {
    group_definition {
      title            = "Quick Stats"
      background_color = "vivid_green"
      show_title       = true
      layout_type      = "ordered"

      widget {
        timeseries_definition {
          title         = "Active Users"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.active{$env, $staff, window:7d}.fill(last)"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.users.active{$env, $staff, window:7d}.fill(last)"
              alias_name = "7 days"
            }
          }
          request {
            q            = "avg:platform.users.active{$env, $staff, window:30d}.fill(last)"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:platform.users.active{$env, $staff, window:30d}.fill(last)"
              alias_name = "30 days"
            }
          }
          request {
            q            = "avg:platform.users.active{$env, $staff, window:180d}.fill(last)"
            display_type = "line"
            style { palette = "warm" }
            metadata {
              expression = "avg:platform.users.active{$env, $staff, window:180d}.fill(last)"
              alias_name = "6 months"
            }
          }
        }
      }
      widget {
        query_value_definition {
          title       = "Total Requests (Web)"
          title_size  = "16"
          title_align = "left"
          autoscale   = true
          text_align  = "center"
          precision   = 0
          request {
            q          = "default_zero(avg:platform.request{$env, $staff, $authenticated, $version, $user_agent}.as_count())"
            aggregator = "sum"
          }
          timeseries_background { type = "bars" }
        }
      }
      widget {
        query_value_definition {
          title       = "Total Requests (App)"
          title_size  = "16"
          title_align = "left"
          autoscale   = true
          text_align  = "center"
          precision   = 0
          request {
            q          = "default_zero(avg:platform.request{$env, $staff, $authenticated, $version, user_agent:mobile_app_flutter}.as_count())"
            aggregator = "sum"
          }
          timeseries_background { type = "bars" }
        }
      }
      widget {
        timeseries_definition {
          title         = "Logins"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{$env, $version, status_code:200, method:post, path:auth.token}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
            metadata {
              expression = "sum:platform.request{$env, $version, status_code:200, method:post, path:auth.token}.as_count()"
              alias_name = "Frontend"
            }
          }
          request {
            q            = "sum:platform.request{$env, $version, status_code:200, method:post, path:auth.token.legacy}.as_count()"
            display_type = "bars"
            style { palette = "warm" }
            metadata {
              expression = "sum:platform.request{$env, $version, status_code:200, method:post, path:auth.token.legacy}.as_count()"
              alias_name = "Legacy Frontend"
            }
          }
        }
      }
      widget {
        query_value_definition {
          title     = "Account's Activated (non-Staff)"
          autoscale = false
          precision = 0
          request {
            q          = "default_zero(sum:platform.action.user.verified{$env,$version, $user_agent, staff:false}.as_count())"
            aggregator = "sum"
          }
          timeseries_background { type = "bars" }
        }
      }
      widget {
        query_value_definition {
          title     = "Account's Deleted (non-Staff)"
          autoscale = false
          precision = 0
          request {
            q          = "default_zero(sum:platform.task{$env,$version, $user_agent,staff:false,name:user.delete}.as_count())"
            aggregator = "sum"
          }
          timeseries_background { type = "bars" }
        }
      }
      widget {
        query_value_definition {
          title       = "Reminders Sent"
          title_size  = "16"
          title_align = "left"
          autoscale   = false
          precision   = 0
          request {
            q          = "default_zero(avg:platform.action.email.sent{$env, $version, type:reminder}.as_count() + avg:platform.action.push.sent{$env, $version}.as_count())"
            aggregator = "sum"
          }
          timeseries_background { type = "bars" }
        }
      }
      widget {
        toplist_definition {
          title       = "Slowest Endpoints (p95 ms)"
          title_size  = "16"
          title_align = "left"
          request {
            q = "avg:platform.request.timing.95percentile{$env, $user_agent, $authenticated, $version, !path:planner.courseschedules.events} by {path}"
          }
        }
      }
    }
  }

  # Critical Alerts Group
  widget {
    group_definition {
      title            = "Critical Signals"
      background_color = "vivid_yellow"
      show_title       = true
      layout_type      = "ordered"

      widget {
        query_value_definition {
          title     = "Total Failures (24h)"
          autoscale = false
          precision = 0
          request {
            q          = "default_zero(sum:platform.action.email.failed{$env}.as_count() + sum:platform.action.push.failed{$env}.as_count() + sum:platform.external.firebase.failed{$env}.as_count() + sum:platform.feed.ical.failed{$env}.as_count() + sum:platform.task.failed{$env}.as_count())"
            aggregator = "sum"
          }
          timeseries_background { type = "bars" }
        }
      }
      widget {
        timeseries_definition {
          title         = "Task Failures"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.task.failed{$env, $version} by {name}.as_count()"
            display_type = "bars"
            style { palette = "red" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Firebase/OAuth Failures"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.external.firebase.failed{$env, $version}.as_count()"
            display_type = "bars"
            style { palette = "red" }
            metadata {
              expression = "sum:platform.external.firebase.failed{$env, $version}.as_count()"
              alias_name = "Firebase Failures"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Push Delivery Failures"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.action.push.failed{$env, $version}.as_count()"
            display_type = "bars"
            style { palette = "red" }
            metadata {
              expression = "sum:platform.action.push.failed{$env, $version}.as_count()"
              alias_name = "Push Failures"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Email Delivery Failures"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.action.email.failed{$env, $version}.as_count()"
            display_type = "bars"
            style { palette = "red" }
            metadata {
              expression = "sum:platform.action.email.failed{$env, $version}.as_count()"
              alias_name = "Email Failures"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Calendar Sync Failures"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.feed.ical.failed{$env, $version} by {reason}.as_count()"
            display_type = "bars"
            style { palette = "red" }
          }
        }
      }
    }
  }

  # API Metrics Group
  widget {
    group_definition {
      title            = "API Metrics"
      background_color = "vivid_blue"
      show_title       = true
      layout_type      = "ordered"

      widget {
        timeseries_definition {
          title         = "API Memory Utilization (%)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:aws.ecs.memory_utilization{clustername:helium_$env.value, servicename:*api*}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:aws.ecs.memory_utilization{clustername:helium_$env.value, servicename:*api*}"
              alias_name = "Memory %"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "API CPU Utilization (%)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:aws.ecs.cpuutilization{clustername:helium_$env.value, servicename:*api*}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:aws.ecs.cpuutilization{clustername:helium_$env.value, servicename:*api*}"
              alias_name = "CPU %"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "API Running Tasks"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:aws.ecs.service.running{clustername:helium_$env.value, servicename:*api*}"
            display_type = "area"
            style { palette = "cool" }
            metadata {
              expression = "avg:aws.ecs.service.running{clustername:helium_$env.value, servicename:*api*}"
              alias_name = "Running Tasks"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Requests by Route (Top 10)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "top(sum:platform.request{$env, $staff, $authenticated, $version, $user_agent} by {path}.as_count(), 10, 'sum', 'desc')"
            display_type = "bars"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Endpoint Response Time (Top 5 Slowest, ms)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "top(avg:platform.request.timing.95percentile{$env, $authenticated, $version, $user_agent, !path:planner.courseschedules.events} by {path}, 5, 'mean', 'desc')"
            display_type = "line"
            style { palette = "warm" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "500s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{status_code:500, $env, $authenticated, $version, $user_agent} by {path}.as_count()"
            display_type = "bars"
            style { palette = "red" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "400s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{status_code:400, $env, $staff, $authenticated, $version, $user_agent} by {path}.as_count()"
            display_type = "bars"
            style { palette = "orange" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "429s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{status_code:429, $env, $staff, $authenticated, $version, $user_agent} by {path}.as_count()"
            display_type = "bars"
            style { palette = "orange" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "/feed/*.ics 200s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{$env,status_code:200, method:get,$user_agent, $version ,path:feed.private.*.ics} by {path}.as_count()"
            display_type = "bars"
            style { palette = "green" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "/feed/externalcalendars/events 200s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{$env, $staff, status_code:200, method:get, $user_agent, $version, path:feed.externalcalendars.events}.as_count()"
            display_type = "bars"
            style { palette = "green" }
            metadata {
              expression = "sum:platform.request{$env, $staff, status_code:200, method:get, $user_agent, $version, path:feed.externalcalendars.events}.as_count()"
              alias_name = "path:feed.externalcalendars.events"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Import/Export"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{$env, $staff, $version, path:importexport.import}.as_count()"
            display_type = "bars"
            style { palette = "blue" }
            metadata {
              expression = "sum:platform.request{$env, $staff, $version, path:importexport.import}.as_count()"
              alias_name = "File Import"
            }
          }
          request {
            q            = "sum:platform.request{$env, $staff, $version, path:importexport.export}.as_count()"
            display_type = "bars"
            style { palette = "green" }
            metadata {
              expression = "sum:platform.request{$env, $staff, $version, path:importexport.export}.as_count()"
              alias_name = "Export"
            }
          }
          request {
            q            = "sum:platform.request{$env, $staff, $version, path:importexport.import.exampleschedule}.as_count()"
            display_type = "bars"
            style { palette = "purple" }
            metadata {
              expression = "sum:platform.request{$env, $staff, $version, path:importexport.import.exampleschedule}.as_count()"
              alias_name = "Example Schedule"
            }
          }
        }
      }
    }
  }

  # Worker Metrics Group
  widget {
    group_definition {
      title            = "Worker Metrics"
      background_color = "pink"
      show_title       = true
      layout_type      = "ordered"

      widget {
        timeseries_definition {
          title         = "Worker Memory Utilization (%)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:aws.ecs.memory_utilization{clustername:helium_$env.value, servicename:*worker*}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:aws.ecs.memory_utilization{clustername:helium_$env.value, servicename:*worker*}"
              alias_name = "Memory %"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Worker CPU Utilization (%)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:aws.ecs.cpuutilization{clustername:helium_$env.value, servicename:*worker*}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:aws.ecs.cpuutilization{clustername:helium_$env.value, servicename:*worker*}"
              alias_name = "CPU %"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Worker Running Tasks"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:aws.ecs.service.running{clustername:helium_$env.value, servicename:*worker*}"
            display_type = "area"
            style { palette = "cool" }
            metadata {
              expression = "avg:aws.ecs.service.running{clustername:helium_$env.value, servicename:*worker*}"
              alias_name = "Running Tasks"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Celery Queue Depth"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.celery.queue.depth{$env}"
            display_type = "line"
            style { palette = "orange" }
            metadata {
              expression = "avg:platform.celery.queue.depth{$env}"
              alias_name = "Queue Depth"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Task Runtime by Name (p95 ms)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.task.timing.95percentile{$env} by {name}"
            display_type = "line"
            style { palette = "purple" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Task Queue Wait Time (ms)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.task.queue_time.avg{$env, priority:high}"
            display_type = "line"
            style {
              palette    = "warm"
              line_width = "normal"
            }
            metadata {
              expression = "avg:platform.task.queue_time.avg{$env, priority:high}"
              alias_name = "High Priority"
            }
          }
          request {
            q            = "avg:platform.task.queue_time.avg{$env, priority:low}"
            display_type = "line"
            style {
              palette    = "cool"
              line_width = "normal"
            }
            metadata {
              expression = "avg:platform.task.queue_time.avg{$env, priority:low}"
              alias_name = "Low Priority"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Notifications Sent"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.action.email.sent{$env, $version, type:reminder}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
            metadata {
              expression = "sum:platform.action.email.sent{$env, $version, type:reminder}.as_count()"
              alias_name = "Emails"
            }
          }
          request {
            q            = "sum:platform.action.push.sent{$env, $version}.as_count()"
            display_type = "bars"
            style { palette = "purple" }
            metadata {
              expression = "sum:platform.action.push.sent{$env, $version}.as_count()"
              alias_name = "Push"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Refresh Tokens"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.task{$env, $version, name:token.refresh.*} by {name}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
            metadata {
              expression = "sum:platform.task{$env, $version, name:token.refresh.*} by {name}.as_count()"
              alias_name = "Refresh Tokens"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "User Purge Operations"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.task{$env, $version, name:user.unverified.purge}.as_count()"
            display_type = "bars"
            style { palette = "blue" }
            metadata {
              expression = "sum:platform.task{$env, $version, name:user.unverified.purge}.as_count()"
              alias_name = "Unverified Purged"
            }
          }
          request {
            q            = "avg:platform.users.dormant.warnings_sent{$env}"
            display_type = "bars"
            style { palette = "orange" }
            metadata {
              expression = "avg:platform.users.dormant.warnings_sent{$env}"
              alias_name = "Dormant Warnings Sent"
            }
          }
          request {
            q            = "avg:platform.users.dormant.deletions_queued{$env}"
            display_type = "bars"
            style { palette = "red" }
            metadata {
              expression = "avg:platform.users.dormant.deletions_queued{$env}"
              alias_name = "Dormant Deletions Queued"
            }
          }
        }
      }
    }
  }

  # AWS Metrics (Actionable) - 15 min lag from CloudWatch
  widget {
    group_definition {
      title            = "AWS Metrics (Actionable)"
      background_color = "vivid_orange"
      show_title       = true
      layout_type      = "ordered"

      widget {
        timeseries_definition {
          title       = "CloudFront Error Rate (%)"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "sum:aws.cloudfront.5xx_error_rate{environment:$env.value}.weighted()"
            display_type = "bars"
            style { palette = "red" }
            metadata {
              expression = "sum:aws.cloudfront.5xx_error_rate{environment:$env.value}.weighted()"
              alias_name = "5xx Error Rate"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "ALB Errors"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:aws.applicationelb.httpcode_elb_5xx{name:helium-$env.value}.as_count()"
            display_type = "bars"
            style { palette = "warm" }
            metadata {
              expression = "sum:aws.applicationelb.httpcode_elb_5xx{name:helium-$env.value}.as_count()"
              alias_name = "ELB 5xx"
            }
          }
          request {
            q            = "sum:aws.applicationelb.httpcode_target_5xx{name:helium-$env.value}.as_count()"
            display_type = "bars"
            style { palette = "warm" }
            metadata {
              expression = "sum:aws.applicationelb.httpcode_target_5xx{name:helium-$env.value}.as_count()"
              alias_name = "Target 5xx"
            }
          }
          request {
            q            = "sum:aws.applicationelb.target_connection_error_count{name:helium-$env.value}.as_count()"
            display_type = "bars"
            style { palette = "warm" }
            metadata {
              expression = "sum:aws.applicationelb.target_connection_error_count{name:helium-$env.value}.as_count()"
              alias_name = "Connection Errors"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "SES Bounce Rate (%)"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.ses.reputation_bounce_rate{*} * 100"
            display_type = "line"
            style { palette = "red" }
            metadata {
              expression = "avg:aws.ses.reputation_bounce_rate{*} * 100"
              alias_name = "Bounce Rate %"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "SES Complaint Rate (%)"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.ses.reputation_complaint_rate{*} * 100"
            display_type = "line"
            style { palette = "orange" }
            metadata {
              expression = "avg:aws.ses.reputation_complaint_rate{*} * 100"
              alias_name = "Complaint Rate %"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "ALB Healthy Targets"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.applicationelb.healthy_host_count{name:helium-$env.value}"
            display_type = "area"
            style { palette = "cool" }
            metadata {
              expression = "avg:aws.applicationelb.healthy_host_count{name:helium-$env.value}"
              alias_name = "Healthy Targets"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "ALB Active Connections"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.applicationelb.active_connection_count{name:helium-$env.value}"
            display_type = "line"
            style { palette = "purple" }
            metadata {
              expression = "avg:aws.applicationelb.active_connection_count{name:helium-$env.value}"
              alias_name = "Active Connections"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "RDS Connections"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "sum:aws.rds.database_connections{name:helium-$env.value}.weighted()"
            display_type = "area"
            style { palette = "dog_classic" }
            metadata {
              expression = "sum:aws.rds.database_connections{name:helium-$env.value}.weighted()"
              alias_name = "DB Connections"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "RDS CPU Utilization (%)"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.rds.cpuutilization{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:aws.rds.cpuutilization{name:helium-$env.value}"
              alias_name = "CPU %"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "RDS Available RAM (bytes)"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.rds.freeable_memory{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:aws.rds.freeable_memory{name:helium-$env.value}"
              alias_name = "Freeable Memory"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Redis Connections"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "sum:aws.elasticache.curr_connections{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "sum:aws.elasticache.curr_connections{name:helium-$env.value}"
              alias_name = "Connections"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Redis CPU Utilization (%)"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.elasticache.cpuutilization{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:aws.elasticache.cpuutilization{name:helium-$env.value}"
              alias_name = "CPU %"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Redis Available RAM (bytes)"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.elasticache.freeable_memory{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:aws.elasticache.freeable_memory{name:helium-$env.value}"
              alias_name = "Freeable Memory"
            }
          }
        }
      }
    }
  }

  # AWS Metrics (Retrospective)
  widget {
    group_definition {
      title            = "AWS Metrics (Retrospective)"
      background_color = "gray"
      show_title       = true
      layout_type      = "ordered"

      widget {
        timeseries_definition {
          title       = "CloudFront Requests"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "sum:aws.cloudfront.requests{environment:$env.value}.as_count()"
            display_type = "bars"
            style { palette = "green" }
            metadata {
              expression = "sum:aws.cloudfront.requests{environment:$env.value}.as_count()"
              alias_name = "Requests"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "RDS Network Throughput (bytes/s)"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.rds.network_transmit_throughput{name:helium-$env.value}"
            display_type = "line"
            style { palette = "purple" }
            metadata {
              expression = "avg:aws.rds.network_transmit_throughput{name:helium-$env.value}"
              alias_name = "Transmit"
            }
          }
          request {
            q            = "avg:aws.rds.network_receive_throughput{name:helium-$env.value}"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:aws.rds.network_receive_throughput{name:helium-$env.value}"
              alias_name = "Receive"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Redis Network Throughput (bytes/s)"
          title_size  = "16"
          title_align = "left"
          show_legend = true
          request {
            q            = "sum:aws.elasticache.network_bytes_in{name:helium-$env.value}.as_rate()"
            display_type = "line"
            style { palette = "purple" }
            metadata {
              expression = "sum:aws.elasticache.network_bytes_in{name:helium-$env.value}.as_rate()"
              alias_name = "Bytes In"
            }
          }
          request {
            q            = "avg:aws.elasticache.network_bytes_out{name:helium-$env.value}.as_rate()"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:aws.elasticache.network_bytes_out{name:helium-$env.value}.as_rate()"
              alias_name = "Bytes Out"
            }
          }
        }
      }
    }
  }
}

resource "datadog_monitor" "high_priority_queue_wait" {
  name    = "High Priority Task Queue Wait Time Elevated"
  type    = "query alert"
  message = <<-EOT
    High priority tasks are waiting in the queue for extended periods (p95 above {{ threshold }} ms over the last hour).

    This indicates the worker may be overwhelmed with low-priority tasks,
    and it may be time to split into separate high/low priority queues.

    Current p95 queue wait time: {{ value }} ms

    Notify: @support@heliumedu.com
  EOT

  query = "avg(last_1h):avg:platform.task.queue_time.95percentile{env:prod, priority:high} > 60000"

  monitor_thresholds {
    critical = 60000
    warning  = 45000
  }

  priority            = 4
  include_tags        = false
  on_missing_data     = "default"
  require_full_window = false
  renotify_interval   = 120

  tags = ["managed_by:terraform", "alert_type:config"]
}
