data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type        = "Service"
    }
  }
}

resource "aws_iam_role" "ecs_role" {
  name = "helium-${var.environment}-ecs-task-role"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_execution_policy" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "logs:CreateLogStream",
      "logs:CreateLogGroup",
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "helium-${var.environment}-ecs-execution-policy"
  role = aws_iam_role.ecs_role.id

  policy = data.aws_iam_policy_document.ecs_task_execution_policy.json
}

data "aws_iam_policy_document" "get_secret_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:GetSecretValue",
      "secretsmanager:DescribeSecret"
    ]
    resources = [
      "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:${var.environment}/helium**"
    ]
  }
}

resource "aws_iam_role_policy" "get_secret_policy" {
  name = "helium-${var.environment}-get-secret-policy"
  role = aws_iam_role.ecs_role.id

  policy = data.aws_iam_policy_document.get_secret_policy_document.json
}

data "aws_iam_policy_document" "ses_suppression_policy_document" {
  statement {
    effect    = "Allow"
    actions   = ["ses:DeleteSuppressedDestination", "ses:PutSuppressedDestination"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ses_suppression_policy" {
  name = "helium-${var.environment}-ses-suppression-policy"
  role = aws_iam_role.ecs_role.id

  policy = data.aws_iam_policy_document.ses_suppression_policy_document.json
}

locals {
  arch_tag = var.default_arch == "ARM64" ? "arm64" : "amd64"
}

resource "aws_cloudwatch_log_group" "platform" {
  name              = "/ecs/helium_platform_${var.environment}"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "platform_resource_task" {
  family = "helium_platform_resource_${var.environment}"
  container_definitions = jsonencode([
    {
      name      = "helium_platform_resource"
      image     = "${var.platform_resource_repository_uri}:${local.arch_tag}-${var.helium_version}"
      cpu       = 0
      essential = true
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "USE_AWS_SECRETS_MANAGER"
          value = "True"
        },
        {
          name  = "TZ"
          value = "UTC"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.platform.name
          mode                  = "non-blocking"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  cpu    = "256"
  memory = "512"

  task_role_arn      = aws_iam_role.ecs_role.arn
  execution_role_arn = aws_iam_role.ecs_role.arn
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]

  runtime_platform {
    cpu_architecture        = var.default_arch
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_task_definition" "platform_api_service" {
  family = "helium_platform_api_${var.environment}"
  container_definitions = jsonencode([
    {
      name      = "helium_platform_api"
      image     = "${var.platform_api_repository_uri}:${local.arch_tag}-${var.helium_version}"
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = 8000
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "USE_AWS_SECRETS_MANAGER"
          value = "True"
        },
        {
          name  = "TZ"
          value = "UTC"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.platform.name
          mode                  = "non-blocking"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name      = "datadog-statsd"
      image     = "datadog/dogstatsd:latest"
      cpu       = 0
      essential = false
      environment = [
        {
          name  = "DD_API_KEY"
          value = var.datadog_api_key
        },
        {
          name  = "DD_SITE"
          value = "datadoghq.com"
        },
        {
          name  = "DD_ENV"
          value = var.environment
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.platform.name
          mode                  = "non-blocking"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  cpu    = "1024"
  memory = "2048"

  task_role_arn      = aws_iam_role.ecs_role.arn
  execution_role_arn = aws_iam_role.ecs_role.arn
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]

  runtime_platform {
    cpu_architecture        = var.default_arch
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_task_definition" "platform_worker_service" {
  family = "helium_platform_worker_${var.environment}"
  container_definitions = jsonencode([
    {
      name      = "helium_platform_worker"
      image     = "${var.platform_worker_repository_uri}:${local.arch_tag}-${var.helium_version}"
      cpu       = 0
      essential = true
      environment = [
        {
          name  = "ENVIRONMENT"
          value = var.environment
        },
        {
          name  = "USE_AWS_SECRETS_MANAGER"
          value = "True"
        },
        {
          name  = "TZ"
          value = "UTC"
        },
        {
          name  = "CELERY_CONCURRENCY"
          value = tostring(var.celery_concurrency)
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.platform.name
          mode                  = "non-blocking"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    },
    {
      name      = "datadog-statsd"
      image     = "datadog/dogstatsd:latest"
      cpu       = 0
      essential = false
      environment = [
        {
          name  = "DD_API_KEY"
          value = var.datadog_api_key
        },
        {
          name  = "DD_SITE"
          value = "datadoghq.com"
        },
        {
          name  = "DD_ENV"
          value = var.environment
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.platform.name
          mode                  = "non-blocking"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  cpu    = "256"
  memory = "1024"

  task_role_arn      = aws_iam_role.ecs_role.arn
  execution_role_arn = aws_iam_role.ecs_role.arn
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]

  runtime_platform {
    cpu_architecture        = var.default_arch
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_cluster" "helium" {
  name = "helium_${var.environment}"
}

resource "aws_ecs_cluster_capacity_providers" "helium" {
  cluster_name = aws_ecs_cluster.helium.name

  capacity_providers = ["FARGATE"]
}

resource "terraform_data" "helium_platform_resource" {
  triggers_replace = [
    aws_ecs_task_definition.platform_resource_task.revision
  ]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-euo", "pipefail", "-c"]
    command     = <<-SCRIPT
      export AWS_DEFAULT_REGION="${var.aws_region}"
      CLUSTER="${aws_ecs_cluster.helium.id}"
      TASK_DEF="${aws_ecs_task_definition.platform_resource_task.arn}"
      SUBNETS="${join(",", var.subnet_ids)}"

      TASK_ARN=$(aws ecs run-task \
        --cluster "$CLUSTER" \
        --task-definition "$TASK_DEF" \
        --launch-type FARGATE \
        --network-configuration "awsvpcConfiguration={subnets=[$SUBNETS],assignPublicIp=ENABLED}" \
        --query 'tasks[0].taskArn' \
        --output text)

      echo "Launched resource task: $TASK_ARN"

      aws ecs wait tasks-stopped --cluster "$CLUSTER" --tasks "$TASK_ARN"

      EXIT_CODE=$(aws ecs describe-tasks \
        --cluster "$CLUSTER" \
        --tasks "$TASK_ARN" \
        --query 'tasks[0].containers[0].exitCode' \
        --output text)

      echo "Resource task exited with code: $EXIT_CODE"

      if [ "$EXIT_CODE" != "0" ]; then
        STOP_REASON=$(aws ecs describe-tasks \
          --cluster "$CLUSTER" \
          --tasks "$TASK_ARN" \
          --query 'tasks[0].stoppedReason' \
          --output text)
        echo "ERROR: Resource task failed — $STOP_REASON"
        exit 1
      fi
    SCRIPT
  }
}

resource "aws_ecs_service" "helium_platform_api" {
  name                               = "helium_platform_api"
  cluster                            = aws_ecs_cluster.helium.id
  task_definition                    = aws_ecs_task_definition.platform_api_service.arn
  desired_count                      = var.platform_host_count
  health_check_grace_period_seconds  = var.request_timeout_seconds * 2
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  network_configuration {
    subnets          = [for id in var.subnet_ids : id]
    security_groups  = [var.http_platform]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.platform_target_group
    container_name   = "helium_platform_api"
    container_port   = 8000
  }

  force_new_deployment = true
  triggers = {
    redeployment = plantimestamp()
  }

  depends_on = [terraform_data.helium_platform_resource]

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_ecs_service" "helium_platform_worker" {
  name                               = "helium_platform_worker"
  cluster                            = aws_ecs_cluster.helium.id
  task_definition                    = aws_ecs_task_definition.platform_worker_service.arn
  desired_count                      = var.platform_worker_count
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  network_configuration {
    subnets          = [for id in var.subnet_ids : id]
    security_groups  = [var.http_platform]
    assign_public_ip = true
  }

  force_new_deployment = true
  triggers = {
    redeployment = plantimestamp()
  }

  depends_on = [terraform_data.helium_platform_resource]

  lifecycle {
    ignore_changes = [desired_count]
  }
}

# Auto Scaling for Platform API
resource "aws_appautoscaling_target" "platform_api" {
  max_capacity       = var.platform_host_max
  min_capacity       = var.platform_host_min
  resource_id        = "service/${aws_ecs_cluster.helium.name}/${aws_ecs_service.helium_platform_api.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "platform_api_cpu" {
  name               = "helium-${var.environment}-api-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.platform_api.resource_id
  scalable_dimension = aws_appautoscaling_target.platform_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.platform_api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_appautoscaling_policy" "platform_api_memory" {
  name               = "helium-${var.environment}-api-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.platform_api.resource_id
  scalable_dimension = aws_appautoscaling_target.platform_api.scalable_dimension
  service_namespace  = aws_appautoscaling_target.platform_api.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 70.0
  }
}

# Auto Scaling for Platform Worker
resource "aws_appautoscaling_target" "platform_worker" {
  max_capacity       = var.platform_worker_max
  min_capacity       = var.platform_worker_min
  resource_id        = "service/${aws_ecs_cluster.helium.name}/${aws_ecs_service.helium_platform_worker.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "platform_worker_cpu" {
  name               = "helium-${var.environment}-worker-cpu-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.platform_worker.resource_id
  scalable_dimension = aws_appautoscaling_target.platform_worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.platform_worker.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70.0
  }
}

resource "aws_appautoscaling_policy" "platform_worker_memory" {
  name               = "helium-${var.environment}-worker-memory-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.platform_worker.resource_id
  scalable_dimension = aws_appautoscaling_target.platform_worker.scalable_dimension
  service_namespace  = aws_appautoscaling_target.platform_worker.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageMemoryUtilization"
    }
    target_value = 80.0
  }
}

# CloudWatch Logs Insights saved queries

resource "aws_cloudwatch_query_definition" "errors" {
  name = "Helium ${var.environment}/Errors"

  log_group_names = [aws_cloudwatch_log_group.platform.name]

  query_string = <<-EOT
    fields @timestamp, @logStream, @message
    | filter @message like /ERROR/ or @message like /CRITICAL/
    | sort @timestamp desc
    | limit 200
  EOT
}

resource "aws_cloudwatch_query_definition" "celery_failures" {
  name = "Helium ${var.environment}/Celery Task Failures"

  log_group_names = [aws_cloudwatch_log_group.platform.name]

  query_string = <<-EOT
    fields @timestamp, @logStream, @message
    | filter @message like /raised unexpected/
    | sort @timestamp desc
    | limit 100
  EOT
}

resource "aws_cloudwatch_query_definition" "push_notifications" {
  name = "Helium ${var.environment}/Push Notifications"

  log_group_names = [aws_cloudwatch_log_group.platform.name]

  query_string = <<-EOT
    fields @timestamp, @logStream, @message
    | filter @message like /Sending pushes for reminder/ or @message like /push notification/ or @message like /helium.common.services.pushservice/
    | sort @timestamp desc
    | limit 100
  EOT
}

# CloudWatch metric filter: emit a data point per Celery task exception so
# the CloudWatch alarm below can detect failure spikes.
resource "aws_cloudwatch_log_metric_filter" "celery_task_failures" {
  name           = "helium-${var.environment}-celery-task-failures"
  pattern        = "raised unexpected"
  log_group_name = aws_cloudwatch_log_group.platform.name

  metric_transformation {
    name      = "CeleryTaskFailure"
    namespace = "Helium/${var.environment}"
    value     = "1"
  }
}

resource "aws_sns_topic" "cloudwatch_alarms" {
  count = var.environment == "prod" ? 1 : 0

  name = "helium-${var.environment}-cloudwatch-alarms"
}

resource "aws_sns_topic_subscription" "cloudwatch_alarms_email" {
  count = var.environment == "prod" ? 1 : 0

  topic_arn = aws_sns_topic.cloudwatch_alarms[0].arn
  protocol  = "email"
  endpoint  = "support@heliumedu.com"
}

resource "aws_cloudwatch_metric_alarm" "celery_task_failures" {
  count = var.environment == "prod" ? 1 : 0

  alarm_name        = "helium-${var.environment}-celery-task-failure-spike"
  alarm_description = "More than 5 background task failures detected in the last hour. Celery workers and task processing should be investigated."

  namespace   = "Helium/${var.environment}"
  metric_name = "CeleryTaskFailure"
  statistic   = "Sum"

  period             = 3600
  evaluation_periods = 1
  threshold          = 5
  comparison_operator = "GreaterThanThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alarms[0].arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alarms[0].arn]
}

# Alarms when the worker ECS service has no running tasks. AWS/ECS stops
# publishing CPUUtilization when there are no tasks, so treat_missing_data
# = breaching is the detection mechanism; the threshold comparison acts as
# a safety net for a near-zero but technically-present data point.
resource "aws_cloudwatch_metric_alarm" "worker_tasks_down" {
  count = var.environment == "prod" ? 1 : 0

  alarm_name        = "helium-${var.environment}-worker-tasks-down"
  alarm_description = "No ECS worker tasks have been running for 5+ minutes. Background task processing (reminders, purges, etc.) has stopped."

  namespace   = "AWS/ECS"
  metric_name = "CPUUtilization"
  dimensions = {
    ClusterName = aws_ecs_cluster.helium.name
    ServiceName = aws_ecs_service.helium_platform_worker.name
  }
  statistic   = "Average"

  period             = 300
  evaluation_periods = 1
  threshold          = 0.05
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "breaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alarms[0].arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alarms[0].arn]
}

resource "aws_cloudwatch_metric_alarm" "rds_low_storage" {
  count = var.environment == "prod" ? 1 : 0

  alarm_name        = "helium-${var.environment}-rds-low-storage"
  alarm_description = "RDS free storage is below 2 GB. Expand allocated storage before the instance goes read-only."

  namespace   = "AWS/RDS"
  metric_name = "FreeStorageSpace"
  dimensions = {
    DBInstanceIdentifier = "helium-${var.environment}"
  }
  statistic   = "Average"

  period             = 300
  evaluation_periods = 3
  threshold          = 2147483648
  comparison_operator = "LessThanThreshold"
  treat_missing_data  = "notBreaching"

  alarm_actions = [aws_sns_topic.cloudwatch_alarms[0].arn]
  ok_actions    = [aws_sns_topic.cloudwatch_alarms[0].arn]
}
