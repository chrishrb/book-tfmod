# ****************************************************************************
#
# Aurora serverless v2
#
# ****************************************************************************

locals {
  cluster_identifier = "${var.service_prefix}-database"
}

resource "aws_db_subnet_group" "book_db" {
  name       = "${var.service_prefix}-main"
  subnet_ids = data.aws_subnets.private.ids

  tags = {
    "Name" = "${var.service_prefix}-private-db-subnet-group"
    "tier" = "private"
  }
}

# WARN: do not use in production!
resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_rds_cluster" "book_db" {
  cluster_identifier  = local.cluster_identifier
  engine              = "aurora-postgresql"
  engine_mode         = "provisioned"
  engine_version      = "14.9"
  database_name       = "bookdb"
  master_username     = "postgres"
  master_password     = random_password.password.result
  apply_immediately   = true
  skip_final_snapshot = true

  db_subnet_group_name = aws_db_subnet_group.book_db.name
  vpc_security_group_ids = flatten([
    data.aws_security_groups.allow_postgres.ids,
  ])

  serverlessv2_scaling_configuration {
    max_capacity = 5.0
    min_capacity = 0.5
  }
}

resource "aws_rds_cluster_instance" "book_db" {
  cluster_identifier = aws_rds_cluster.book_db.id
  instance_class     = "db.serverless"
  engine             = aws_rds_cluster.book_db.engine
  engine_version     = aws_rds_cluster.book_db.engine_version
}
