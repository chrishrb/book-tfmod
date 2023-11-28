# ***************************************************************************
#
# Variables
#
# ***************************************************************************

variable "stage_name" {
  description = "Name of the stage (v1)"
  type        = string
  default     = "v1"
}

variable "burst_limit" {
  description = "short-term maximum concurrent requests limit"
  type        = number
  default     = 200
}

variable "rate_limit" {
  description = "steady maximum concurrent requests limit"
  type        = number
  default     = 100
}

# ****************************************************************************
#
# Module specific inputs
#
# ****************************************************************************

variable "openapi_yaml_file" {
  description = "OpenAPI file which specifies the API gateway"
  type        = string
}

# ****************************************************************************
#
# Common inputs
#
# ****************************************************************************

variable "log_retention_days" {
  type = number
}

variable "service_prefix" {
  type = string
}
