resource "datadog_integration_aws_account" "helium" {
  aws_account_id = var.aws_account_id
  aws_partition  = "aws"

  auth_config {
    aws_auth_config_role {
      role_name = "DatadogIntegrationRole"
    }
  }

  aws_regions {
    include_only = ["us-east-1"]
  }

  metrics_config {
    enabled                   = true
    automute_enabled          = false
    collect_cloudwatch_alarms = false

    namespace_filters {
      include_only = [
        "AWS/ApplicationELB",
        "AWS/CloudFront",
        "AWS/ECS",
        "AWS/ElastiCache",
        "AWS/RDS",
        "AWS/SES",
        "Helium/Platform",
      ]
    }
  }

  resources_config {
    extended_collection = false
  }

  logs_config {
    lambda_forwarder {}
  }

  traces_config {
    xray_services {}
  }
}
