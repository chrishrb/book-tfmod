# ***************************************************************************
#
# Outputs
#
# ***************************************************************************

output "api_gw_id" {
  value = aws_api_gateway_rest_api.api_gw.id
}

output "api_gw_url" {
  value = aws_api_gateway_stage.api_gw.invoke_url
}
