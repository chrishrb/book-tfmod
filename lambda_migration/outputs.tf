# ****************************************************************************
#
# Outputs
#
# ****************************************************************************

output "lambda_name" {
  value = aws_lambda_function.book_migration.function_name
}
