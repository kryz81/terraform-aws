output "instance" {
  value     = aws_instance.kryz_node[*]
  sensitive = true
}
