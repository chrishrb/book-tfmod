# ****************************************************************************
#
# ECS Service
#
# ****************************************************************************

resource "aws_ecs_service" "book_monolith" {
  name            = "book_monolith"
  cluster         = aws_ecs_cluster.book.id
  task_definition = aws_ecs_task_definition.book_monolith.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  force_new_deployment = true

  health_check_grace_period_seconds = 120
  platform_version                  = "LATEST"

  deployment_minimum_healthy_percent = 100
  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }
  deployment_controller {
    type = "ECS"
  }

  load_balancer {
    container_name   = "book_monolith"
    container_port   = 3000
    target_group_arn = aws_lb_target_group.book_monolith.arn
  }

  propagate_tags = "TASK_DEFINITION"

  network_configuration {
    security_groups = flatten([
      data.aws_security_groups.allow_local.ids,
    ])
    subnets = flatten([
      data.aws_subnets.private.ids,
    ])
    assign_public_ip = false
  }

  depends_on            = [aws_iam_role_policy_attachment.book_monolith]
  wait_for_steady_state = true
}

# ****************************************************************************
#
# ECS TaskDefinition
#
# ****************************************************************************

resource "aws_ecs_task_definition" "book_monolith" {
  requires_compatibilities = ["FARGATE"]
  family                   = "book_monolith"
  cpu                      = 256
  memory                   = 512
  network_mode             = "awsvpc"
  task_role_arn            = aws_iam_role.book_monolith.arn
  execution_role_arn       = aws_iam_role.ecs_task.arn

  container_definitions = jsonencode([
    {
      name      = "book_monolith"
      image     = "${data.aws_caller_identity.current.account_id}.dkr.ecr.${data.aws_region.current.name}.amazonaws.com/book-monolith:0.1.4"
      essential = true
      environment = [
        {
          name  = "POSTGRES_HOST"
          value = var.postgres_host
        },
        {
          name  = "POSTGRES_PORT"
          value = "5432"
        },
        {
          name  = "POSTGRES_DB"
          value = var.postgres_db
        },
        {
          name  = "SSL_MODE"
          value = "require"
        },
        // TODO: move to secretsmanager
        {
          name  = "POSTGRES_USERNAME"
          value = var.postgres_username
        },
        // TODO: move to secretsmanager
        {
          name  = "POSTGRES_PASSWORD"
          value = var.postgres_password
        }
      ]
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.book_monolith.name,
          awslogs-region        = data.aws_region.current.name,
          awslogs-stream-prefix = "book"
        }
      },
      portMappings = [{
        containerPort = 3000
      }]
      healthCheck = {
        retries = 10
        command = ["CMD-SHELL", "curl -f http://localhost:3000 || exit 1"]
        timeout : 5
        interval : 10
        startPeriod : 10
      }
      requires_compatibilities = "FARGATE"
    }
  ])
}

# ****************************************************************************
#
# IAM
#
# ****************************************************************************

resource "aws_iam_role" "book_monolith" {
  name               = "book-monolithTaskRole"
  description        = "ECS Task role"
  assume_role_policy = data.aws_iam_policy_document.book_monolith_assume.json
}

data "aws_iam_policy_document" "book_monolith_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "book_monolith" {
  role       = aws_iam_role.book_monolith.name
  policy_arn = aws_iam_policy.book_monolith.arn
}

resource "aws_iam_policy" "book_monolith" {
  name        = "BookTask"
  description = "Permissions for book task"

  policy = data.aws_iam_policy_document.book_monolith.json
}

data "aws_iam_policy_document" "book_monolith" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]
    resources = [
      aws_cloudwatch_log_group.book_monolith.arn,
      "${aws_cloudwatch_log_group.book_monolith.arn}:log-stream:*",
    ]
  }
}

# ****************************************************************************
#
# Logs
#
# ****************************************************************************

resource "aws_cloudwatch_log_group" "book_monolith" {
  name              = "${local.task_log_prefix}/book_monolith"
  retention_in_days = var.log_retention_days
}
