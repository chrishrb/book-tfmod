# ***************************************************************************
#
# Locals
#
# ***************************************************************************

locals {
  ecs_cluster_name   = "${var.service_prefix}-ecs"
  cluster_log_prefix = "/aws/ecs"
  task_log_prefix    = "/aws/ecs-task"
}
