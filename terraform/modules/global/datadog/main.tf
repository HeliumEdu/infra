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
          title         = "Total Requests"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{$env, $staff, $authenticated, $version, $user_agent} by {client}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
          }
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
            q            = "sum:platform.request{$env, $version, status_code:200, method:post, path:auth.token*} by {path}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        query_value_definition {
          title     = "Accounts Activated (non-Staff)"
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
          title     = "Accounts Deleted (non-Staff)"
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
        toplist_definition {
          title       = "Slowest Endpoints (p95 ms)"
          title_size  = "16"
          title_align = "left"
          request {
            q = "avg:platform.request.timing.95percentile{$env, $user_agent, $authenticated, $version} by {path}"
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "User Setup Duration (ms)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.user.setup.total_duration.avg{$env, $version}"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.user.setup.total_duration.avg{$env, $version}"
              alias_name = "Setup Duration"
            }
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
            q            = "top(avg:platform.request.timing.95percentile{$env, $authenticated, $version, $user_agent} by {path}, 5, 'mean', 'desc')"
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
            q            = "sum:platform.request{$env, $staff, $version, path:importexport.*} by {path}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
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
          title         = "Reminders Sent"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.action.reminder.sent{$env, $version} by {channel}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Emails Sent"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.action.email.sent{$env, $version, !type:reminder} by {type}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
            metadata {
              expression = "sum:platform.action.email.sent{$env, $version, !type:reminder} by {type}.as_count()"
              alias_name = "Emails"
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
          title         = "Dangling User Purge"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.task{$env, $version, name:user.dangling.purge}.as_count()"
            display_type = "bars"
            style { palette = "blue" }
            metadata {
              expression = "sum:platform.task{$env, $version, name:user.dangling.purge}.as_count()"
              alias_name = "Dangling Purged"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Dormant User Operations"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.dormant.operations{$env} by {operation}"
            display_type = "bars"
            style { palette = "dog_classic" }
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

resource "datadog_dashboard" "helium_user_behavior" {
  title       = "Helium User Behavior"
  description = "Managed by Terraform"
  layout_type = "ordered"
  reflow_type = "auto"

  template_variable {
    name     = "env"
    prefix   = "env"
    defaults = ["prod"]
  }
  template_variable {
    name     = "staff"
    prefix   = "staff"
    defaults = ["false"]
  }
  template_variable {
    name     = "window"
    prefix   = "window"
    defaults = ["30d"]
  }

  # Engagement Overview Group
  widget {
    group_definition {
      title            = "Engagement Overview"
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
        timeseries_definition {
          title         = "Logins"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{$env, status_code:200, method:post, path:auth.token OR path:auth.token.legacy} by {path}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        query_value_definition {
          title     = "Accounts Activated (non-Staff)"
          autoscale = false
          precision = 0
          request {
            q          = "default_zero(sum:platform.action.user.verified{$env, staff:false}.as_count())"
            aggregator = "sum"
          }
          timeseries_background { type = "bars" }
        }
      }
      widget {
        timeseries_definition {
          title         = "Users with Active Classes"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.engagement.has_active_courses{$env, $staff}.fill(last)"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.users.engagement.has_active_courses{$env, $staff}.fill(last)"
              alias_name = "Has Active Classes"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Completions per User (14d rolling)"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.engagement.avg_completions_per_user{$env, $staff}.fill(last)"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:platform.users.engagement.avg_completions_per_user{$env, $staff}.fill(last)"
              alias_name = "Avg Completions / User"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Graded Assignments per User"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.engagement.avg_graded_homework_per_user{$env, $staff}.fill(last)"
            display_type = "line"
            style { palette = "warm" }
            metadata {
              expression = "avg:platform.users.engagement.avg_graded_homework_per_user{$env, $staff}.fill(last)"
              alias_name = "Avg Graded Assignments / User"
            }
          }
        }
      }
    }
  }

  # Data Richness Group
  widget {
    group_definition {
      title            = "Data Richness"
      background_color = "vivid_blue"
      show_title       = true
      layout_type      = "ordered"

      widget {
        timeseries_definition {
          title         = "Avg Assignments per Class"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_homework_per_course{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.users.data.avg_homework_per_course{$env, $staff, $window}.fill(last)"
              alias_name = "Avg Assignments / Class"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Assignments per User"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_homework_per_user{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.users.data.avg_homework_per_user{$env, $staff, $window}.fill(last)"
              alias_name = "Avg Assignments / User"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Classes per Group"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_courses_per_group{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.users.data.avg_courses_per_group{$env, $staff, $window}.fill(last)"
              alias_name = "Avg Classes / Group"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Events per User"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_events_per_user{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:platform.users.data.avg_events_per_user{$env, $staff, $window}.fill(last)"
              alias_name = "Avg Events / User"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg External Calendars per User"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_external_calendars_per_user{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:platform.users.data.avg_external_calendars_per_user{$env, $staff, $window}.fill(last)"
              alias_name = "Avg External Calendars / User"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Notes per User"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, !entity:*}.fill(last)"
            display_type = "line"
            style {
              palette    = "purple"
              line_type  = "solid"
              line_width = "thick"
            }
            metadata {
              expression = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, !entity:*}.fill(last)"
              alias_name = "Total"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, entity:homework}.fill(last)"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, entity:homework}.fill(last)"
              alias_name = "Assignment"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, entity:event}.fill(last)"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, entity:event}.fill(last)"
              alias_name = "Event"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, entity:resource}.fill(last)"
            display_type = "line"
            style { palette = "warm" }
            metadata {
              expression = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, entity:resource}.fill(last)"
              alias_name = "Resource"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, entity:standalone}.fill(last)"
            display_type = "line"
            style { palette = "gray" }
            metadata {
              expression = "avg:platform.users.data.avg_notes_per_user{$env, $staff, $window, entity:standalone}.fill(last)"
              alias_name = "Standalone"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Reminders per User"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_reminders_per_user{$env, $staff, $window, !entity:*}.fill(last)"
            display_type = "line"
            style {
              palette    = "orange"
              line_type  = "solid"
              line_width = "thick"
            }
            metadata {
              expression = "avg:platform.users.data.avg_reminders_per_user{$env, $staff, $window, !entity:*}.fill(last)"
              alias_name = "Total"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_reminders_per_user{$env, $staff, $window, entity:homework}.fill(last)"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.users.data.avg_reminders_per_user{$env, $staff, $window, entity:homework}.fill(last)"
              alias_name = "Assignment"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_reminders_per_user{$env, $staff, $window, entity:event}.fill(last)"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:platform.users.data.avg_reminders_per_user{$env, $staff, $window, entity:event}.fill(last)"
              alias_name = "Event"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_reminders_per_user{$env, $staff, $window, entity:course}.fill(last)"
            display_type = "line"
            style { palette = "warm" }
            metadata {
              expression = "avg:platform.users.data.avg_reminders_per_user{$env, $staff, $window, entity:course}.fill(last)"
              alias_name = "Class"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Graded Assignments per Class"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_graded_homework_per_course{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "warm" }
            metadata {
              expression = "avg:platform.users.data.avg_graded_homework_per_course{$env, $staff, $window}.fill(last)"
              alias_name = "Avg Graded Assignments / Class"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Attachments per User"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_attachments_per_user{$env, $staff, $window, !entity:*}.fill(last)"
            display_type = "line"
            style {
              palette    = "gray"
              line_type  = "solid"
              line_width = "thick"
            }
            metadata {
              expression = "avg:platform.users.data.avg_attachments_per_user{$env, $staff, $window, !entity:*}.fill(last)"
              alias_name = "Total"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_attachments_per_user{$env, $staff, $window, entity:homework}.fill(last)"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.users.data.avg_attachments_per_user{$env, $staff, $window, entity:homework}.fill(last)"
              alias_name = "Assignment"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_attachments_per_user{$env, $staff, $window, entity:event}.fill(last)"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:platform.users.data.avg_attachments_per_user{$env, $staff, $window, entity:event}.fill(last)"
              alias_name = "Event"
            }
          }
          request {
            q            = "avg:platform.users.data.avg_attachments_per_user{$env, $staff, $window, entity:course}.fill(last)"
            display_type = "line"
            style { palette = "warm" }
            metadata {
              expression = "avg:platform.users.data.avg_attachments_per_user{$env, $staff, $window, entity:course}.fill(last)"
              alias_name = "Class"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Avg Resources per User"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.data.avg_resources_per_user{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "warm" }
            metadata {
              expression = "avg:platform.users.data.avg_resources_per_user{$env, $staff, $window}.fill(last)"
              alias_name = "Avg Resources / User"
            }
          }
        }
      }
    }
  }

  # Feature Adoption Group
  widget {
    group_definition {
      title            = "Feature Adoption"
      background_color = "vivid_orange"
      show_title       = true
      layout_type      = "ordered"

      widget {
        timeseries_definition {
          title         = "Grade Tracking"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.adoption.grade_tracking{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "dog_classic" }
            metadata {
              expression = "avg:platform.users.adoption.grade_tracking{$env, $staff, $window}.fill(last)"
              alias_name = "Grade Tracking"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "External Calendars"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.adoption.external_calendars{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "cool" }
            metadata {
              expression = "avg:platform.users.adoption.external_calendars{$env, $staff, $window}.fill(last)"
              alias_name = "External Calendars"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Notebook"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.adoption.notebook{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "purple" }
            metadata {
              expression = "avg:platform.users.adoption.notebook{$env, $staff, $window}.fill(last)"
              alias_name = "Notebook"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Resources"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.adoption.resources{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "warm" }
            metadata {
              expression = "avg:platform.users.adoption.resources{$env, $staff, $window}.fill(last)"
              alias_name = "Resources"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Reminders"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.adoption.reminders{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "orange" }
            metadata {
              expression = "avg:platform.users.adoption.reminders{$env, $staff, $window}.fill(last)"
              alias_name = "Reminders"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Attachments"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.adoption.attachments{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "gray" }
            metadata {
              expression = "avg:platform.users.adoption.attachments{$env, $staff, $window}.fill(last)"
              alias_name = "Attachments"
            }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Feeds"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.users.adoption.feeds{$env, $staff, $window}.fill(last)"
            display_type = "line"
            style { palette = "green" }
            metadata {
              expression = "avg:platform.users.adoption.feeds{$env, $staff, $window}.fill(last)"
              alias_name = "Feeds"
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
