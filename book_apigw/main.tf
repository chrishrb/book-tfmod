# ***************************************************************************
#
# Prepare external resources
#
# ***************************************************************************

data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# ***************************************************************************
#
# API Gateway
#
# ***************************************************************************

resource "aws_api_gateway_rest_api" "api_gw" {
  name        = local.api_gw_title
  description = local.api_gw_desc

  body = local.api_gw_body

  endpoint_configuration {
    types = ["REGIONAL"]
  }
}


# ***************************************************************************
#
# API Gateway - deployment
#
# ***************************************************************************

resource "aws_api_gateway_deployment" "api_gw" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(local.api_gw_body)
  }
}

resource "aws_api_gateway_stage" "api_gw" {
  deployment_id        = aws_api_gateway_deployment.api_gw.id
  rest_api_id          = aws_api_gateway_rest_api.api_gw.id
  stage_name           = var.stage_name
  xray_tracing_enabled = true

  depends_on = [
    aws_api_gateway_account.api_gw
  ]
}

# ***************************************************************************
#
# API Gateway - logging
#
# ***************************************************************************

resource "aws_cloudwatch_log_group" "api_gw" {
  name              = "API-Gateway-Execution-Logs_${aws_api_gateway_rest_api.api_gw.id}/${var.stage_name}"
  retention_in_days = var.log_retention_days
}

resource "aws_api_gateway_method_settings" "api_gw" {
  rest_api_id = aws_api_gateway_rest_api.api_gw.id
  stage_name  = aws_api_gateway_stage.api_gw.stage_name
  method_path = "*/*"

  settings {
    metrics_enabled = true
    logging_level   = "ERROR"
  }
}

resource "aws_api_gateway_account" "api_gw" {
  cloudwatch_role_arn = aws_iam_role.api_gw.arn
}

resource "aws_iam_role" "api_gw" {
  name = aws_api_gateway_rest_api.api_gw.name

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "",
      "Effect": "Allow",
      "Principal": {
        "Service": "apigateway.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "cloudwatch" {
  name = "${aws_api_gateway_rest_api.api_gw.name}-cloudwatch"
  role = aws_iam_role.api_gw.id

  policy = data.aws_iam_policy_document.cloudwatch.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents"
    ]
    resources = ["*"]
  }
}
