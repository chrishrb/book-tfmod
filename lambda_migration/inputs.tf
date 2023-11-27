# ****************************************************************************
#
# Module specific inputs
#
# ****************************************************************************

variable "lambda_binary" {}

variable "postgres_host" {}

variable "postgres_username" {}

variable "postgres_password" {}

variable "postgres_db" {}

variable "migration_directory" {}

# ****************************************************************************
#
# Common inputs
#
# ****************************************************************************

variable "log_retention_days" {
  type = number
}

variable "vpc_id" {}

variable "service_prefix" {}
