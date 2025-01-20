############public route table##########

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = var.tgw_id
  }
  tags = {
    Name = "${var.name}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.number_of_public_subnets
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

############private route table##########

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[0].id
  }

  route {
    cidr_block         = "10.0.0.0/8"
    transit_gateway_id = var.tgw_id
  }

  tags = {
    Name = "${var.name}-private-rt"
  }
}



resource "aws_route_table_association" "private" {
  count = var.number_of_private_subnets

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "db" {
  count = var.number_of_database_subnets

  subnet_id      = aws_subnet.database[count.index].id
  route_table_id = aws_route_table.private.id
}