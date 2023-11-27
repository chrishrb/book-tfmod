# ****************************************************************************
#
# Outputs
#
# ****************************************************************************

output "external_asn_sns_arn" {
  value = aws_sns_topic.example.arn
}

output "external_asn_sns_name" {
  value = aws_sns_topic.example.name
}
