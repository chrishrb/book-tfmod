data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# ****************************************************************************
#
# ECR
#
# ****************************************************************************

resource "aws_ecr_repository" "ecr" {
  name = "${var.service_prefix}-monolith"

  # must be IMMUTABLE to work with K8s node cache
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  # Safety gate, as there are no backups of the ECR repos
  lifecycle {
    # WARNING: DO NOT CHANGE
    # If you want to delete a repository, delete manually from AWS
    # prevent_destroy = true
  }
}

# ****************************************************************************
#
# IAM
#
# ****************************************************************************

resource "aws_ecr_repository_policy" "access" {
  repository = aws_ecr_repository.ecr.name
  policy     = data.aws_iam_policy_document.access.json
}

data "aws_iam_policy_document" "access" {
  statement {
    effect = "Allow"
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:CompleteLayerUpload",
      "ecr:DescribeImages",
      "ecr:GetAuthorizationToken",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:ListImages",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
    ]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
  }
}
