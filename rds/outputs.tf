# ****************************************************************************
#
# Outputs
#
# ****************************************************************************

output "endpoint" {
  value = aws_rds_cluster.book_db.endpoint
}

output "master_username" {
  value = aws_rds_cluster.book_db.master_username
}

output "master_password" {
  value = random_password.password.result
}

output "database_name" {
  value = aws_rds_cluster.book_db.database_name
}
