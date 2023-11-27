# ****************************************************************************
#
# Outputs
#
# ****************************************************************************

output "vpc_id" {
  value = aws_vpc.main.id
}

output "security_group_allow_http_name" {
  value = aws_security_group.allow_http.name
}

output "security_group_allow_https_name" {
  value = aws_security_group.allow_https.name
}

output "security_group_allow_local_name" {
  value = aws_security_group.allow_local.name
}

output "security_group_allow_postgres_name" {
  value = aws_security_group.allow_postgres.name
}
