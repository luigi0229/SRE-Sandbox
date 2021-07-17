resource "aws_vpc" "tf_VPC" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = {
    Name = "SRE_Exercise_VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id     = aws_vpc.tf_VPC.id
  cidr_block = var.public_cidr
  availability_zone = "us-east-1a"

  tags = {
    Name = "Public_Subnet"
  }
}

# resource "aws_subnet" "private_subnet" {
#   vpc_id     = aws_vpc.tf_VPC.id
#   cidr_block = var.private_cidr
#
#   tags = {
#     Name = "Private_Subnet"
#   }
# }

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.tf_VPC.id

  tags = {
    Name = "Internet_GW"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id

}

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.tf_VPC.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public_route_table"
  }
}
