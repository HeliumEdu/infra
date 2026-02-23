data "aws_iam_policy_document" "ecs_assume_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      identifiers = ["ecs-tasks.amazonaws.com"]
      type = "Service"
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
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/helium_platform_${var.environment}"
          mode                  = "non-blocking"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
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

resource "aws_ecs_task_definition" "platform_service" {
  family = "helium_platform_${var.environment}"
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
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/helium_platform_${var.environment}"
          mode                  = "non-blocking"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
        }
      }
    },
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
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/helium_platform_${var.environment}"
          mode                  = "non-blocking"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
        }
      }
    },
    {
      name      = "datadog-agent"
      image     = "public.ecr.aws/datadog/agent:latest"
      cpu       = 0
      essential = false
      environment = [
        {
          name  = "ECS_FARGATE"
          value = "true"
        },
        {
          name  = "DD_API_KEY"
          value = var.datadog_api_key
        }
      ]
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

resource "aws_ecs_task_definition" "platform_beat_service" {
  family = "helium_platform_beat_${var.environment}"
  container_definitions = jsonencode([
    {
      name      = "helium_platform_beat"
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
          name  = "PLATFORM_BEAT_MODE"
          value = "True"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/helium_platform_${var.environment}"
          mode                  = "non-blocking"
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
          awslogs-create-group  = "true"
        }
      }
    },
    {
      name      = "datadog-agent"
      image     = "public.ecr.aws/datadog/agent:latest"
      cpu       = 0
      essential = false
      environment = [
        {
          name  = "ECS_FARGATE"
          value = "true"
        },
        {
          name  = "DD_API_KEY"
          value = var.datadog_api_key
        }
      ]
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

resource "aws_ecs_service" "helium_platform" {
  name                               = "helium_platform"
  cluster                            = aws_ecs_cluster.helium.id
  task_definition                    = aws_ecs_task_definition.platform_service.arn
  desired_count                      = var.platform_host_count
  health_check_grace_period_seconds  = 10
  deployment_minimum_healthy_percent = 100
  deployment_maximum_percent         = 200

  capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  network_configuration {
    subnets          = [for id in var.subnet_ids : id]
    security_groups = [var.http_platform]
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
}

# This service can never be autoscaled, only one Beat scheduler should ever be running at a time
resource "aws_ecs_service" "helium_platform_beat" {
  name                       = "helium_platform_beat"
  cluster                    = aws_ecs_cluster.helium.id
  task_definition = aws_ecs_task_definition.platform_beat_service.arn
  # Never set to more than 1, as only one Beat scheduler can be deployed at a time to ensure no duplication of tasks
  desired_count = 1
  # Set to 0 to ensure the existing Beat scheduler is stopped before deploying the new one, thus ensuring no duplication of tasks during deployment
  deployment_minimum_healthy_percent = 0
  # Never allow more than 100%, as only one Beat scheduler can be deployed at a time to ensure no duplication of tasks
  deployment_maximum_percent = 100

  capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  network_configuration {
    subnets          = [for id in var.subnet_ids : id]
    assign_public_ip = true
  }

  force_new_deployment = true
  triggers = {
    redeployment = plantimestamp()
  }
}