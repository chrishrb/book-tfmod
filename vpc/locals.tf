# ***************************************************************************
#
# Locals
#
# ***************************************************************************

locals {
  subnet_count = random_shuffle.azs.result_count
  subnet_bits  = ceil(log(local.subnet_count, 2))

  private_cidr = cidrsubnet(var.cidr, 1, 1)
  public_cidr  = cidrsubnet(var.cidr, 1, 0)

  private_subnets = [for i in range(local.subnet_count) : cidrsubnet(local.private_cidr, local.subnet_bits, i)]
  public_subnets  = [for i in range(local.subnet_count) : cidrsubnet(local.public_cidr, local.subnet_bits, i)]
}
