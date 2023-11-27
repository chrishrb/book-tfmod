# ****************************************************************************
#
# Local settings
#
# ****************************************************************************

locals {
  api_gw_body = file(var.openapi_yaml_file)

  api_gw_title = "${var.service_prefix}-${trimprefix(regex("  title: [\\w- ]+", local.api_gw_body), "  title: ")}"

  api_gw_desc = trimprefix(regex("  description: [^\\r\\n]+", local.api_gw_body), "  description: ")
}
