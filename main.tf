resource "aws_vpc" "flask-vpc" {
  cidr_block           = "10.0.0.0/16"
  instance_tenancy     = "default"
  enable_dns_hostnames = true 

  tags = {
    Name = "flask_vpc"
  }
}

resource "aws_subnet" "flask-public" {
  vpc_id     = aws_vpc.flask-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "flask-public"
  }
}

resource "aws_subnet" "flask-private" {
  vpc_id     = aws_vpc.flask-vpc.id
  cidr_block = "10.0.2.0/24"

  tags = {
    Name = "flask-private"
  }
}

resource "aws_subnet" "flask-local" {
  vpc_id     = aws_vpc.flask-vpc.id
  cidr_block = "10.0.3.0/24"

  tags = {
    Name = "flask-private"
  }
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.flask-vpc.id

  tags = {
    Name = "flask-GTW"
  }
}

resource "aws_route_table" "flask-routing-public" {
  vpc_id = aws_vpc.flask-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public Route Table"
  }
}

resource "aws_route_table_association" "pub-route-table" {
  subnet_id      = aws_subnet.flask-public.id
  route_table_id = aws_route_table.flask-routing-public.id
}

resource "aws_eip" "elp" {
  domain           = "vpc"
}

resource "aws_nat_gateway" "nat-gw" {
  allocation_id = aws_eip.elp.id
  subnet_id     = aws_subnet.flask-public.id

  tags = {
    Name = "gw NAT"
  }

  depends_on = [aws_internet_gateway.gw]
}

resource "aws_route_table" "flask-routing-nat" {
  vpc_id = aws_vpc.flask-vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gw.id
  }

  tags = {
    Name = "NAT Route Table"
  }
}

resource "aws_route_table_association" "prv-route-table" {
  subnet_id      = aws_subnet.flask-private.id
  route_table_id = aws_route_table.flask-routing-nat.id
}

