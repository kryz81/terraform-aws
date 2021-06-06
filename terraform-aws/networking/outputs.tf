output "vpc_id" {
  value = aws_vpc.kryz_vpc.id
}

output "db_subnet_group_name" {
  value = aws_db_subnet_group.kryz_rds_subnetgroup.*.name
}

output "db_security_group" {
  value = [aws_security_group.kryz_sg["rds"].id]
}

output "public_sg" {
  value = aws_security_group.kryz_sg["public"].id
}

output "public_subnets" {
  value = aws_subnet.kryz_public_subnet.*.id
}
