locals {
  hourly_workflows = {
    check_alb_dns = {
      repo     = "infra"
      workflow = "check-alb-dns.yml"
      body     = jsonencode({ ref = "main", return_run_details = false })
    }
    canary = {
      repo     = "frontend"
      workflow = "canary.yml"
      body     = jsonencode({ ref = "develop", inputs = { environment = "prod" }, return_run_details = false })
    }
  }
}

resource "datadog_synthetics_global_variable" "github_pat" {
  name        = "GITHUB_PAT"
  description = "Fine-grained GitHub personal access token with Actions write access to HeliumEdu repositories"
  value       = var.github_pat
  secure      = true
  tags        = ["managed_by:terraform"]
}

resource "datadog_synthetics_test" "workflow_dispatch" {
  for_each = local.hourly_workflows

  name      = "Hourly Dispatch - ${each.value.repo}/${each.value.workflow}"
  type      = "api"
  subtype   = "http"
  status    = "live"
  locations = ["gcp:us-east4"]
  message   = <<-EOT
    Datadog could not dispatch ${each.value.workflow} in HeliumEdu/${each.value.repo}, so its hourly run did not start:
    - GITHUB_PAT may have expired or lost Actions write access to the repository
    - The workflow file may have been renamed, or its dispatch ref no longer exists
    - GitHub's API may be degraded

    Notify: @alerts@heliumedu.com
  EOT

  request_definition {
    method    = "POST"
    url       = "https://api.github.com/repos/HeliumEdu/${each.value.repo}/actions/workflows/${each.value.workflow}/dispatches"
    body      = each.value.body
    body_type = "application/json"
  }

  request_headers = {
    Accept                 = "application/vnd.github+json"
    Authorization          = "Bearer {{ GITHUB_PAT }}"
    "X-GitHub-Api-Version" = "2022-11-28"
  }

  assertion {
    type     = "statusCode"
    operator = "is"
    target   = "204"
  }

  config_variable {
    type = "global"
    name = "GITHUB_PAT"
    id   = datadog_synthetics_global_variable.github_pat.id
  }

  options_list {
    tick_every       = 3600
    monitor_priority = 3

    retry {
      count    = 2
      interval = 60000
    }

    monitor_options {
      renotify_interval = 1440
    }
  }

  tags = ["managed_by:terraform", "alert_type:diagnostic"]
}
