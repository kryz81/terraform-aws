data "aws_availability_zones" "available" {
  state = "available"
}

resource "random_shuffle" "az_list" {
  input        = data.aws_availability_zones.available.names
  result_count = var.max_subnets
}

resource "random_integer" "random" {
  min = 1
  max = 100
}

resource "aws_vpc" "kryz_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "kryz_vpc_${random_integer.random.result}"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "kryz_public_subnet" {
  count                   = var.public_sn_count
  vpc_id                  = aws_vpc.kryz_vpc.id
  cidr_block              = var.public_cidrs[count.index]
  map_public_ip_on_launch = true
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "kryz_public_${count.index + 1}"
  }
}

resource "aws_subnet" "kryz_private_subnet" {
  count                   = var.private_sn_count
  vpc_id                  = aws_vpc.kryz_vpc.id
  cidr_block              = var.private_cidrs[count.index]
  map_public_ip_on_launch = false
  availability_zone       = random_shuffle.az_list.result[count.index]

  tags = {
    Name = "kryz_private_${count.index + 1}"
  }
}

resource "aws_internet_gateway" "kryz_internet_gateway" {
  vpc_id = aws_vpc.kryz_vpc.id

  tags = {
    Name = "kryz_igw"
  }
}
resource "aws_route_table" "kryz_public_rt" {
  vpc_id = aws_vpc.kryz_vpc.id

  tags = {
    Name = "kryz_public"
  }
}

resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.kryz_public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.kryz_internet_gateway.id
}

resource "aws_default_route_table" "kryz_private_rt" {
  default_route_table_id = aws_vpc.kryz_vpc.default_route_table_id

  tags = {
    Name = "kryz_private"
  }
}

resource "aws_route_table_association" "kryz_public_assoc" {
  count          = var.public_sn_count
  subnet_id      = aws_subnet.kryz_public_subnet.*.id[count.index]
  route_table_id = aws_route_table.kryz_public_rt.id
}

resource "aws_security_group" "kryz_sg" {

  for_each = var.security_groups

  vpc_id      = aws_vpc.kryz_vpc.id
  name        = each.value.name
  description = each.value.description

  dynamic "ingress" {
    for_each = each.value.ingress

    content {
      from_port   = ingress.value.from
      protocol    = ingress.value.protocol
      to_port     = ingress.value.to
      cidr_blocks = ingress.value.cidr_blocks
    }
  }

  egress {
    from_port   = 22
    protocol    = "TCP"
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_subnet_group" "kryz_rds_subnetgroup" {
  count      = var.db_subnet_group == true ? 1 : 0
  subnet_ids = aws_subnet.kryz_private_subnet.*.id
  name       = "kryz_rds_subnetgroup"

  tags = {
    Name = "kryz_rds_sng"
  }
}
