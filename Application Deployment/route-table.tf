resource "aws_route_table" "RT" {
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  route_table_id = aws_route_table.RT.id
}
