locals {
  
  nat_gateway_count = var.single_nat ? 1 : lenght(var.azs)
  public_cidr_ranges  = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 3, k)]
  private_cidr_ranges = [for k, v in var.azs : cidrsubnet(var.vpc_cidr, 3, k+3)]
}

resource "aws_vpc" "main" {
  
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = var.enable_dns_hostnames
  enable_dns_support   = var.enable_dns_support

  tags = merge({"Name" = "${var.name}-vpc"}, var.tags)
}
#
#### Public
#

resource "aws_subnet" "public" {
  count = length(local.public_cidr_ranges)

  availability_zone  = var.azs[count.index]
  cidr_block         = local.public_cidr_ranges[count.index]
  vpc_id             = aws_vpc.main.id

  tags = merge(
    {
      "Name" = "${var.name}-${var.public_subnet_suffix}-${count.index}"
    },
  )
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" =  "${var.name}-${var.public_subnet_suffix}-rt"
    }
  )
}

resource "aws_route_table_association" "public" {
  count = length(local.public_cidr_ranges)

  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route" "public" {
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
  route_table_id         = aws_route_table.public.id
}

#
#### Private
#
resource "aws_subnet" "private" {
  count = length(local.private_cidr_ranges)

  availability_zone  = var.azs[count.index]
  cidr_block         = local.private_cidr_ranges[count.index]
  vpc_id             = aws_vpc.main.id

  tags = merge(
    {
      "Name" = "${var.name}-${var.private_subnet_suffix}-${count.index}"
    },
  )
}

resource "aws_route_table" "private" {
  count = local.nat_gateway_count

  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" =  "${var.name}-${var.private_subnet_suffix}-rt-${count.index}"
    }
  )
}

resource "aws_route_table_association" "private" {
  count = length(local.private_cidr_ranges)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[var.single_nat ? 0 : count.index].id
}

resource "aws_route" "private" {
  count = var.enable_nat ? length(aws_route_table.private[*]) : 0

  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.main[count.index].id
  route_table_id         = aws_route_table.private[count.index].id
}
#
#### Internet Gateway
#
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    {
      "Name" =  "${var.name}-igw"
    }
  )
}

resource "aws_eip" "nat" {
  count = var.enable_nat ? local.nat_gateway_count : 0
  
  domain = "vpc"

  tags = merge(
    {
      "Name" =  "${var.name}-eip-${count.index}"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "main" {
  count = var.enable_nat ? local.nat_gateway_count : 0

  allocation_id = aws_eip.nat[count.index].allocation_id
  subnet_id = aws_subnet.public[count.index].id

  tags = merge(
    {
      "Name" =  "${var.name}-natgw-${count.index}"
    }
  )
  depends_on = [aws_internet_gateway.igw]
}
