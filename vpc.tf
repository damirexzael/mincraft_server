# ------------------------------------------------------------------------------
# define the VPC
# ------------------------------------------------------------------------------
resource "aws_vpc" "instance_connect" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(map("Name", "instance-connect"), var.tags)
}

# ------------------------------------------------------------------------------
# define the subnet
# ------------------------------------------------------------------------------
resource "aws_subnet" "instance_connect" {
  vpc_id                  = aws_vpc.instance_connect.id
  cidr_block              = "10.0.0.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags                    = merge(map("Name", "instance-connect-public"), var.tags)
}

resource "aws_internet_gateway" "instance_connect" {
  vpc_id = aws_vpc.instance_connect.id
  tags   = merge(map("Name", "instance-connect-gateway"), var.tags)
}

resource "aws_default_route_table" "instance_connect" {
  default_route_table_id = aws_vpc.instance_connect.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.instance_connect.id
  }

  tags = merge(map("Name", "instance-connect"), var.tags)
}

resource "aws_route_table_association" "instance_connect" {
  subnet_id      = aws_subnet.instance_connect.id
  route_table_id = aws_default_route_table.instance_connect.id
}
