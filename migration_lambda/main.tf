# ****************************************************************************
#
# S3 Bucket
#
# ****************************************************************************

locals {
  lambda_name = "${var.service_prefix}-db-migration-lambda"
}

resource "aws_s3_bucket" "migration_bucket" {
  bucket = "${local.lambda_name}-bucket"
}

resource "aws_s3_object" "migration_bucket" {
  bucket = aws_s3_bucket.migration_bucket.id

  for_each = fileset(var.migration_directory, "*")

  key    = each.value
  source = "${var.migration_directory}/${each.value}"
  etag   = filemd5("${var.migration_directory}/${each.value}")
}

# ****************************************************************************
#
# Lambda for database migrations
#
# ****************************************************************************

resource "aws_lambda_function" "book_migration" {
  function_name = local.lambda_name

  filename = var.lambda_binary
  role     = aws_iam_role.book_migration.arn

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
      POSTGRES_HOST       = var.postgres_host
      POSTGRES_USERNAME   = var.postgres_username
      POSTGRES_PASSWORD   = var.postgres_password
      POSTGRES_DB         = var.postgres_db
      POSTGRES_PORT       = 5432
      MIGRATION_S3_BUCKET = aws_s3_bucket.migration_bucket.id
    }
  }
}

# ****************************************************************************
#
# Execute lambda
#
# ****************************************************************************
resource "aws_lambda_invocation" "book_migration" {
  function_name = aws_lambda_function.book_migration.function_name

  input = jsonencode({
    command = "UP"
  })

  // TODO: trigger also, if migration scripts change
  triggers = {
    redeployment = sha1(jsonencode([
      aws_lambda_function.book_migration.environment
    ]))
  }

  depends_on = [
    aws_s3_object.migration_bucket,
    aws_lambda_function.book_migration
  ]
}

# ****************************************************************************
#
# IAM permissions
#
# ****************************************************************************

data "aws_iam_policy" "AWSLambdaBasicExecutionRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role" "book_migration" {
  name = local.lambda_name

  assume_role_policy = data.aws_iam_policy_document.book_migration_assume.json
}

data "aws_iam_policy_document" "book_migration_assume" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role_policy_attachment" "book_migration_basic" {
  role       = aws_iam_role.book_migration.name
  policy_arn = data.aws_iam_policy.AWSLambdaBasicExecutionRole.arn
}

resource "aws_iam_role_policy_attachment" "AWSLambdaVPCAccessExecutionRole" {
  role       = aws_iam_role.book_migration.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}

# ****************************************************************************
# Allow access to migration s3 bucket
# ****************************************************************************

data "aws_iam_policy_document" "allow_migration_s3" {
  statement {
    effect = "Allow"
    actions = [
      "s3:GetObject",
      "s3:GetObjectAcl",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.migration_bucket.arn}",
      "${aws_s3_bucket.migration_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "allow_migration_s3" {
  name        = "allow-s3-migration"
  description = "Allow access to migration S3 bucket"
  policy      = data.aws_iam_policy_document.allow_migration_s3.json
}

resource "aws_iam_role_policy_attachment" "allow_migration_s3" {
  role       = aws_iam_role.book_migration.name
  policy_arn = aws_iam_policy.allow_migration_s3.arn
}
