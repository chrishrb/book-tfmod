# ****************************************************************************
#
# S3 Bucket
#
# ****************************************************************************

locals {
  bucket_name = "${var.service_prefix}-serverless-frontend"
}

resource "aws_s3_bucket" "frontend_bucket" {
  bucket = local.bucket_name
}

# ****************************************************************************
#
# Policies
#
# ****************************************************************************

resource "aws_s3_bucket_ownership_controls" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false
}

resource "aws_s3_bucket_acl" "frontend_bucket" {
  bucket     = aws_s3_bucket.frontend_bucket.id
  acl        = "public-read"
  depends_on = [aws_s3_bucket_ownership_controls.frontend_bucket]
}


resource "aws_s3_bucket_website_configuration" "frontend_bucket" {
  bucket = aws_s3_bucket.frontend_bucket.id

  index_document {
    suffix = "index.html"
  }

  error_document {
    key = "index.html"
  }
}

data "aws_iam_policy_document" "allow_access_from_public" {
  statement {
    actions = [
      "s3:GetObject"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    resources = [
      "arn:aws:s3:::${local.bucket_name}/*"
    ]
  }
}

resource "aws_s3_bucket_policy" "allow_access_from_public" {
  bucket = aws_s3_bucket.frontend_bucket.id
  policy = data.aws_iam_policy_document.allow_access_from_public.json
}
