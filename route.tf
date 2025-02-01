resource "aws_route_table" "default_route_table" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "${var.environment_prod}-route-table"
    Environment = "${var.environment_prod}"
  }
}
resource "aws_route" "default_route" {
  route_table_id         = aws_route_table.default_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}
resource "aws_route_table_association" "default_association" {
  subnet_id      = aws_subnet.main_subnet.id
  route_table_id = aws_route_table.default_route_table.id
}

resource "aws_route_table_association" "default_association_2" {
  subnet_id      = aws_subnet.main_subnet_2.id
  route_table_id = aws_route_table.default_route_table.id
}