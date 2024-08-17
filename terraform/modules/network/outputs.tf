output "vpc_id" {
  value = aws_vpc.product_categorize_vpc.id
}

output "public_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "public_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
}

output "private_subnet_a_id" {
  value = aws_subnet.public_subnet_a.id
}

output "private_subnet_b_id" {
  value = aws_subnet.public_subnet_b.id
}

output "public_route_table" {
  value = aws_route_table.public_route_table
}
output "private_route_table" {
  value = aws_route_table.private_route_table
}
