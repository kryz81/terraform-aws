output "instances" {
  value     = { for i in module.compute.instance : i.tags.Name => i.public_ip }
  sensitive = true
}
