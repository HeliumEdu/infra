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

resource "aws_cloudwatch_log_group" "platform" {
  name              = "/ecs/helium_platform_${var.environment}"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "platform_resource_task" {
  family = "helium_platform_resource_${var.environment}"
  container_definitions = jsonencode([
    {
      name      = "helium_platform_resource"
      image     = "${var.platform_resource_repository_uri}:amd64-${var.helium_version}"
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
      image     = "${var.platform_api_repository_uri}:amd64-${var.helium_version}"
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
      image     = "${var.platform_worker_repository_uri}:amd64-${var.helium_version}"
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

data "aws_ecs_task_execution" "helium_platform_resource" {
  cluster         = aws_ecs_cluster.helium.id
  task_definition = aws_ecs_task_definition.platform_resource_task.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [for id in var.subnet_ids : id]
    assign_public_ip = true
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
# DataDog can alert without relying solely on DogStatsD from the worker process.
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
