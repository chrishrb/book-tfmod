# ***************************************************************************
#
# Private subnet
#
# ***************************************************************************

resource "aws_subnet" "private" {
  count = local.subnet_count

  cidr_block        = local.private_subnets[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = random_shuffle.azs.result[count.index]

  tags = {
    "Name" = "${var.service_prefix}-${var.vpc_name}-private-${random_shuffle.azs.result[count.index]}"
    "tier" = "private"
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.service_prefix}-${var.vpc_name}-private"
  }
}

resource "aws_route_table_association" "private" {
  count = local.subnet_count

  route_table_id = aws_route_table.private.id
  subnet_id      = aws_subnet.private[count.index].id
}
