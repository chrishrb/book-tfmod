# ****************************************************************************
#
# ECS Cluster
#
# ****************************************************************************

resource "aws_ecs_cluster" "book" {
  name = local.ecs_cluster_name

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_encryption_enabled = true
        cloud_watch_log_group_name     = aws_cloudwatch_log_group.book.name
      }
    }
  }
}

# ***************************************************************************
#
# IAM
#
# ***************************************************************************

resource "aws_iam_role" "ecs_task" {
  name               = "ecsTaskExecutionRole"
  description        = "ECS Task rooe"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# ***************************************************************************
#
# Logs
#
# ***************************************************************************

resource "aws_cloudwatch_log_group" "book" {
  name              = "${local.cluster_log_prefix}/${local.ecs_cluster_name}"
  retention_in_days = var.log_retention_days
}
