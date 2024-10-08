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
  name = "${var.environment}_ecs_task_role"

  assume_role_policy = data.aws_iam_policy_document.ecs_assume_role_policy.json
}

output "task_execution_role_arn" {
  value = aws_iam_role.ecs_role.arn
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
      "logs:PutLogEvents"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecs_task_execution_policy" {
  name = "ECSExecutionPolicy"
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
      "arn:aws:secretsmanager:us-east-1:${var.aws_account_id}:secret:*/helium**"
    ]
  }
}

resource "aws_iam_role_policy" "get_secret_policy" {
  name = "GetSecret"
  role = aws_iam_role.ecs_role.id

  policy = data.aws_iam_policy_document.get_secret_policy_document.json
}

resource "aws_cloudwatch_log_group" "helium_frontend" {
  name              = "/ecs/helium_frontend"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "helium_platform" {
  name              = "/ecs/helium_platform_${var.environment}"
  retention_in_days = 30
}

resource "aws_ecs_task_definition" "frontend_service" {
  family = "helium_frontend"
  container_definitions = jsonencode([
    {
      name      = "helium_frontend"
      image     = "${var.frontend_repository_uri}:${var.helium_version}"
      cpu       = 0
      essential = true
      portMappings = [
        {
          containerPort = 3000
          protocol      = "tcp"
          appProtocol   = "http"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/helium_frontend"
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
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_task_definition" "platform_service" {
  family = "helium_platform_${var.environment}"
  container_definitions = jsonencode([
    {
      name      = "helium_platform_api"
      image     = "${var.platform_api_repository_uri}:${var.helium_version}"
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
      image     = "${var.platform_worker_repository_uri}:${var.helium_version}"
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

  cpu    = "2048"
  memory = "4096"

  task_role_arn      = aws_iam_role.ecs_role.arn
  execution_role_arn = aws_iam_role.ecs_role.arn
  network_mode       = "awsvpc"
  requires_compatibilities = [
    "FARGATE"
  ]

  runtime_platform {
    cpu_architecture        = "X86_64"
    operating_system_family = "LINUX"
  }
}

resource "aws_ecs_cluster" "helium" {
  name = "helium"
}

resource "aws_ecs_cluster_capacity_providers" "helium" {
  cluster_name = aws_ecs_cluster.helium.name

  capacity_providers = ["FARGATE"]
}

resource "aws_ecs_service" "helium_frontend" {
  name                              = "helium_frontend"
  cluster                           = aws_ecs_cluster.helium.id
  task_definition                   = aws_ecs_task_definition.frontend_service.arn
  desired_count                     = 1
  health_check_grace_period_seconds = 10

  capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }

  network_configuration {
    subnets          = [for id in var.subnet_ids : id]
    security_groups = [var.http_frontend]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = var.frontend_target_group
    container_name   = "helium_frontend"
    container_port   = 3000
  }
}

resource "aws_ecs_service" "helium_platform" {
  name                              = "helium_platform"
  cluster                           = aws_ecs_cluster.helium.id
  task_definition                   = aws_ecs_task_definition.platform_service.arn
  desired_count                     = 2
  health_check_grace_period_seconds = 10

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
}