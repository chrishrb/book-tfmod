# INFO only for better calculation of costs, otherwise comment out
# locals {
#   vpc_endpoint_list = tomap({
#     "com.amazonaws.${data.aws_region.current.name}.ecr.api" = "ecr-api",
#     "com.amazonaws.${data.aws_region.current.name}.ecr.dkr" = "ecr-dkr",
#     "com.amazonaws.${data.aws_region.current.name}.logs"    = "logs",
#   })
# }

resource "aws_vpc_endpoint" "ecr_endpoint" {
  # INFO only for better calculation of costs, otherwise comment out
  # for_each = local.vpc_endpoint_list
  for_each = var.vpc_endpoint_list

  vpc_id            = aws_vpc.main.id
  service_name      = each.key
  vpc_endpoint_type = "Interface"

  private_dns_enabled = true
  security_group_ids = [
    aws_security_group.allow_local.id
  ]
  subnet_ids = aws_subnet.private[*].id

  tags = {
    Name = "${var.service_prefix}-${each.value}"
  }
}

resource "aws_vpc_endpoint" "s3_endpoint" {
  vpc_id            = aws_vpc.main.id
  service_name      = "com.amazonaws.${data.aws_region.current.name}.s3"
  vpc_endpoint_type = "Gateway"

  tags = {
    Name = "${var.service_prefix}-s3"
  }
}

resource "aws_vpc_endpoint_route_table_association" "s3_endpoint_private" {
  route_table_id  = aws_route_table.private.id
  vpc_endpoint_id = aws_vpc_endpoint.s3_endpoint.id
}
