resource "aws_nat_gateway" "ngw1" {
    subnet_id = aws_subnet.public_1.id
    allocation_id = aws_eip.nat1.id
    tags = {
      Name="NAT-1"
    }
  
}
resource "aws_nat_gateway" "ngw2" {
    subnet_id = aws_subnet.public_2.id
    allocation_id = aws_eip.nat2.id
    tags = {
      Name="NAT-2"
    }
  
}
