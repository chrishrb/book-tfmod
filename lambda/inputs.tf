# ****************************************************************************
#
# Module specific inputs
#
# ****************************************************************************

variable "lambda_name" {}

variable "lambda_binary" {}

variable "api_gw_id" {}

variable "postgres_host" {}

variable "postgres_username" {}

variable "postgres_password" {}

variable "postgres_db" {}

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
