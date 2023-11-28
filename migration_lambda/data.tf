data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_security_groups" "allow_local" {
  # list of filters: https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
  filter {
    name   = "group-name"
    values = ["allow-local"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_security_groups" "allow_http" {
  # list of filters: https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
  filter {
    name   = "group-name"
    values = ["allow-http"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_security_groups" "allow_https" {
  # list of filters: https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
  filter {
    name   = "group-name"
    values = ["allow-https"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_security_groups" "allow_postgres" {
  # list of filters: https://docs.aws.amazon.com/cli/latest/reference/ec2/describe-security-groups.html
  filter {
    name   = "group-name"
    values = ["allow-postgres"]
  }

  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    tier = "private"
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id]
  }

  tags = {
    tier = "public"
  }
}
