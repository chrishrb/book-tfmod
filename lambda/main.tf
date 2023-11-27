# ****************************************************************************
#
# Lambda
#
# ****************************************************************************

locals {
  lambda_name = "${var.service_prefix}-${var.lambda_name}-lambda"
}

resource "aws_lambda_function" "book_lambda" {
  function_name = local.lambda_name

  filename = var.lambda_binary
  role     = aws_iam_role.book_lambda.arn

  memory_size = 256
  timeout     = 60
  publish     = true
  runtime     = "provided.al2"
  handler     = "bootstrap"

  source_code_hash = filebase64sha256(var.lambda_binary)

  vpc_config {
    security_group_ids = flatten([
      data.aws_security_groups.allow_local.ids,
    ])
    subnet_ids = data.aws_subnets.private.ids
  }

  environment {
    variables = {
      POSTGRES_HOST     = var.postgres_host
      POSTGRES_USERNAME = var.postgres_username
      POSTGRES_PASSWORD = var.postgres_password
      POSTGRES_DB       = var.postgres_db
      POSTGRES_PORT     = 5432
    }
  }
}

# ****************************************************************************
#
# IAM permissions
#
# ****************************************************************************

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "book_lambda" {
  name = local.lambda_name

  assume_role_policy = data.aws_iam_policy_document.book_lambda_assume.json
}

data "aws_iam_policy_document" "book_lambda_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "book_lambda_basic" {
  role       = aws_iam_role.book_lambda.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.book_lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ****************************************************************************
#
# API Gateway trigger
#
# ****************************************************************************

resource "aws_lambda_permission" "book_lambda" {
  statement_id  = "AllowExecutionFromAPIGateway_${aws_lambda_function.book_lambda.function_name}"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.book_lambda.function_name
  principal     = "apigateway.amazonaws.com"

  # More: http://docs.aws.amazon.com/apigateway/latest/developerguide/api-gateway-control-access-using-iam-policies-to-invoke-api.html
  source_arn = "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${var.api_gw_id}/*/*"
}
