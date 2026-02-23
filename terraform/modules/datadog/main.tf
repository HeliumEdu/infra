resource "datadog_dashboard" "helium_heads_up" {
  title       = "Helium Heads Up"
  description = "Platform monitoring dashboard managed by Terraform"
  layout_type = "ordered"
  reflow_type = "auto"

  template_variable {
    name    = "env"
    prefix  = "env"
    default = "prod"
  }
  template_variable {
    name    = "user_agent"
    prefix  = "user_agent"
    default = "*"
  }
  template_variable {
    name    = "authenticated"
    prefix  = "authenticated"
    default = "*"
  }
  template_variable {
    name    = "version"
    prefix  = "version"
    default = "*"
  }
  template_variable {
    name    = "staff"
    prefix  = "staff"
    default = "false"
  }

  # Quick Stats Group
  widget {
    group_definition {
      title            = "Quick Stats"
      background_color = "vivid_green"
      show_title       = true
      layout_type      = "ordered"

      widget {
        query_value_definition {
          title       = "Logins"
          title_size  = "16"
          title_align = "left"
          autoscale   = false
          precision   = 0
          request {
            q          = "avg:platform.action.user.login{$env, $staff, $authenticated, $version, $user_agent}.as_count()"
            aggregator = "sum"
          }
        }
      }
      widget {
        query_value_definition {
          title     = "Account's Activated (non-Staff)"
          autoscale = false
          precision = 0
          request {
            q          = "sum:platform.action.user.verified{$env,$version, $user_agent, staff:false}.as_count()"
            aggregator = "sum"
          }
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
            q          = "avg:platform.action.text.sent{$env, $version}.as_count() + avg:platform.action.email.sent{$env, $version}.as_count() + avg:platform.action.push.sent{$env, $version}.as_count()"
            aggregator = "sum"
          }
        }
      }
      widget {
        query_value_definition {
          title       = "Total Mobile Requests (Browser)"
          title_size  = "16"
          title_align = "left"
          autoscale   = true
          text_align  = "center"
          precision   = 0
          request {
            q          = "avg:platform.request{$env, $staff, $authenticated, $version ,user_agent:mozilla/*iphone*}.as_count() + avg:platform.request{$env, $staff, $authenticated, $version ,user_agent:mozilla/*android*}.as_count()"
            aggregator = "sum"
          }
        }
      }
      widget {
        query_value_definition {
          title       = "Total Mobile Requests (Mobile)"
          title_size  = "16"
          title_align = "left"
          autoscale   = true
          text_align  = "center"
          precision   = 0
          request {
            q          = "avg:platform.request{$env, $staff, $authenticated, $version ,user_agent:dart*}.as_count()"
            aggregator = "sum"
          }
        }
      }
      widget {
        query_value_definition {
          title     = "Account's Deleted (non-Staff)"
          autoscale = false
          precision = 0
          request {
            q          = "sum:platform.task{$env,$version, $user_agent,staff:false,name:user.delete}.as_count()"
            aggregator = "sum"
          }
        }
      }
      widget {
        query_value_definition {
          title       = "Total Requests"
          title_size  = "16"
          title_align = "left"
          autoscale   = true
          text_align  = "center"
          precision   = 0
          request {
            q          = "avg:platform.request{$env, $staff, $authenticated, $version, $user_agent}.as_count()"
            aggregator = "sum"
          }
        }
      }
      widget {
        toplist_definition {
          title       = "Most Used Routes"
          title_size  = "16"
          title_align = "left"
          request {
            q = "sum:platform.request{$env, $user_agent, $authenticated, $staff, $version} by {path}.as_count()"
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
          title         = "/planner 200s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{status_code:200 , $env, $staff, $authenticated, $version, $user_agent, path:planner.*}.as_count()"
            display_type = "bars"
            style { palette = "green" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "/token 200s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{$env,method:post,status_code:200,$version, $user_agent, path:auth.token}.as_count()"
            display_type = "bars"
            style { palette = "green" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "/token/refresh 200s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{$env,status_code:200,method:post, $user_agent, $version, path:auth.token.refresh}.as_count()"
            display_type = "bars"
            style { palette = "green" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "500s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{status_code:500, $env, $staff, $authenticated, $version, $user_agent} by {path}.as_count()"
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
          title         = "/feed/externalcalendars/*/events 200s"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.request{$env,status_code:200, method:get,$user_agent, $version ,path:feed.externalcalendars.events}.as_count()"
            display_type = "bars"
            style { palette = "green" }
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
          title         = "Feed Reindex Time"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.task.timing.avg{$env, name:feed.reindex}"
            display_type = "line"
            style { palette = "purple" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Purge Refresh Tokens Time"
          title_size    = "16"
          title_align   = "left"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "avg:platform.task.timing.avg{$env, name:token.refresh.purge}"
            display_type = "line"
            style { palette = "purple" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Push Notifications Sent"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.action.push.sent{$env, $version}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Texts Sent"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.action.text.sent{$env, $version}.as_count()"
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
            q            = "sum:platform.action.email.sent{$env, $version}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Reminders Queued"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.task{$env, $staff, $version, name:reminder.queue.*} by {name}.as_count()"
            display_type = "bars"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Refresh Tokens Blacklisted"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.task{$env, $version, name:token.refresh.blacklist}.as_count()"
            display_type = "bars"
            style { palette = "blue" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Refresh Tokens Purged"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.task{$env, $version, name:token.refresh.purge}.as_count()"
            display_type = "bars"
            style { palette = "blue" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Unverified Users Purged"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.task{$env, $version, name:user.unverified.purge}.as_count()"
            display_type = "bars"
            style { palette = "blue" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Category Grade Calculation"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.grade.recalculate.category{$env, $version, $staff}.as_count()"
            display_type = "bars"
            style { palette = "orange" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Course Grade Calculation"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.grade.recalculate.course{$env, $version, $staff}.as_count()"
            display_type = "bars"
            style { palette = "orange" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "Course Group Grade Calculation"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.grade.recalculate.course_group{$env, $version, $staff}.as_count()"
            display_type = "bars"
            style { palette = "orange" }
          }
        }
      }
    }
  }

  # AWS Metrics Group
  widget {
    group_definition {
      title            = "AWS Metrics"
      background_color = "vivid_orange"
      show_title       = true
      layout_type      = "ordered"

      widget {
        timeseries_definition {
          title       = "Average memory usage per container"
          title_size  = "16"
          title_align = "left"
          show_legend = false
          request {
            q            = "avg:ecs.fargate.mem.usage{cluster_name:helium_$env.value} by {container_id}"
            display_type = "line"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "CPU percent usage per container"
          title_size  = "16"
          title_align = "left"
          show_legend = false
          request {
            q            = "avg:ecs.fargate.cpu.percent{cluster_name:helium_$env.value} by {container_id}"
            display_type = "line"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Cloudfront Requests"
          title_size  = "13"
          title_align = "left"
          show_legend = true
          request {
            q            = "sum:aws.cloudfront.requests{environment:$env.value}.as_count()"
            display_type = "bars"
            style { palette = "green" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Average bytes sent per container"
          title_size  = "16"
          title_align = "left"
          show_legend = false
          request {
            q            = "avg:ecs.fargate.net.bytes_sent{cluster_name:helium_$env.value} by {container_id}"
            display_type = "line"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Average bytes received per container"
          title_size  = "16"
          title_align = "left"
          show_legend = false
          request {
            q            = "avg:ecs.fargate.net.bytes_rcvd{cluster_name:helium_$env.value} by {container_id}"
            display_type = "line"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Cloudfront Error Rate"
          title_size  = "13"
          title_align = "left"
          show_legend = true
          request {
            q            = "sum:aws.cloudfront.5xx_error_rate{environment:$env.value}.weighted()"
            display_type = "bars"
            style { palette = "red" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "RDS Connections"
          title_size  = "13"
          title_align = "left"
          show_legend = true
          request {
            q            = "sum:aws.rds.database_connections{name:helium-$env.value}.weighted()"
            display_type = "area"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "RDS Network Throughput"
          show_legend = true
          request {
            q            = "avg:aws.rds.network_transmit_throughput{name:helium-$env.value}"
            display_type = "line"
            style { palette = "purple" }
          }
          request {
            q            = "avg:aws.rds.network_receive_throughput{name:helium-$env.value}"
            display_type = "line"
            style { palette = "purple" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "RDS CPU Utilization"
          title_size  = "13"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.rds.cpuutilization{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "RDS Available RAM"
          title_size  = "13"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.rds.freeable_memory{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Redis Connections"
          title_size  = "16"
          title_align = "left"
          show_legend = false
          request {
            q            = "sum:aws.elasticache.curr_connections{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Redis Network Throughput"
          title_size  = "16"
          title_align = "left"
          show_legend = false
          request {
            q            = "sum:aws.elasticache.network_bytes_in{name:helium-$env.value}.as_rate()"
            display_type = "line"
            style { palette = "purple" }
          }
          request {
            q            = "avg:aws.elasticache.network_bytes_out{name:helium-$env.value}.as_rate()"
            display_type = "line"
            style { palette = "purple" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Redis CPU Utilization"
          title_size  = "16"
          title_align = "left"
          show_legend = false
          request {
            q            = "avg:aws.elasticache.cpuutilization{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
          }
        }
      }
      widget {
        timeseries_definition {
          title       = "Redis Available RAM"
          title_size  = "13"
          title_align = "left"
          show_legend = true
          request {
            q            = "avg:aws.elasticache.freeable_memory{name:helium-$env.value}"
            display_type = "line"
            style { palette = "dog_classic" }
          }
        }
      }
    }
  }

  # Critical Alerts Group (NEW - for failure metrics)
  widget {
    group_definition {
      title            = "Critical Alerts"
      background_color = "vivid_red"
      show_title       = true
      layout_type      = "ordered"

      widget {
        timeseries_definition {
          title         = "Email Delivery Failures"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.action.email.failed{$env, $version}.as_count()"
            display_type = "bars"
            style { palette = "red" }
          }
        }
      }
      widget {
        timeseries_definition {
          title         = "SMS Delivery Failures"
          show_legend   = true
          legend_layout = "auto"
          request {
            q            = "sum:platform.action.text.failed{$env, $version}.as_count()"
            display_type = "bars"
            style { palette = "red" }
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
        query_value_definition {
          title     = "Total Failures (24h)"
          autoscale = false
          precision = 0
          request {
            q          = "sum:platform.action.email.failed{$env}.as_count() + sum:platform.action.text.failed{$env}.as_count() + sum:platform.feed.ical.failed{$env}.as_count() + sum:platform.task.failed{$env}.as_count()"
            aggregator = "sum"
          }
        }
      }
    }
  }
}
