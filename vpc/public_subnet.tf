# ***************************************************************************
#
# Public subnet
#
# ***************************************************************************

resource "aws_subnet" "public" {
  count = local.subnet_count

  cidr_block        = local.public_subnets[count.index]
  vpc_id            = aws_vpc.main.id
  availability_zone = random_shuffle.azs.result[count.index]

  tags = {
    "Name" = "${var.service_prefix}-${var.vpc_name}-public-${data.aws_availability_zones.available_azs.names[count.index]}"
    "tier" = "public"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id
  }

  tags = {
    "Name" = "${var.service_prefix}-${var.vpc_name}-public"
  }
}

resource "aws_route_table_association" "public" {
  count = local.subnet_count

  route_table_id = aws_route_table.public.id
  subnet_id      = aws_subnet.public[count.index].id
}

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = {
    "Name" = "${var.service_prefix}-${var.vpc_name}"
  }
}
