#trivy:ignore:AVD-AWS-0178
resource "aws_vpc" "product_categorize_vpc" {
  cidr_block = "10.0.0.0/16"
}
resource "aws_subnet" "public_subnet_a" {
  vpc_id            = aws_vpc.product_categorize_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = var.availability_zone_a

  ## #trivy:ignore:AVD-AWS-0164
  map_public_ip_on_launch = true
}

resource "aws_subnet" "public_subnet_b" {
  vpc_id            = aws_vpc.product_categorize_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = var.availability_zone_b

  ## #trivy:ignore:AVD-AWS-0164
  map_public_ip_on_launch = true
}

resource "aws_subnet" "private_subnet_a" {
  vpc_id            = aws_vpc.product_categorize_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = var.availability_zone_a
}

resource "aws_subnet" "private_subnet_b" {
  vpc_id            = aws_vpc.product_categorize_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = var.availability_zone_b
}

resource "aws_internet_gateway" "product_categorize_igw" {
  vpc_id = aws_vpc.product_categorize_vpc.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "product_categorize_nat_gw" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet_a.id
}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.product_categorize_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.product_categorize_igw.id
  }
}

resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.product_categorize_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.product_categorize_nat_gw.id
  }
}

resource "aws_route_table_association" "subnet_association_a" {
  subnet_id      = aws_subnet.private_subnet_a.id
  route_table_id = aws_route_table.private_route_table.id
}

resource "aws_route_table_association" "subnet_association_b" {
  subnet_id      = aws_subnet.private_subnet_b.id
  route_table_id = aws_route_table.private_route_table.id
}
resource "aws_route_table_association" "public_subnet_association_a" {
  subnet_id      = aws_subnet.public_subnet_a.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_association_b" {
  subnet_id      = aws_subnet.public_subnet_b.id
  route_table_id = aws_route_table.public_route_table.id
}
