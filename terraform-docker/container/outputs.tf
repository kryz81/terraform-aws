#output "container_hostname" {
#  value       = docker_container.nodered_container.hostname
#  description = "Hostname of the container"
#}

#output "container_ip" {
#  value = [for i in docker_container.nodered_container[*] : join(" : ", [i.ip_address, i.ports[0].internal, i.ports[0].external])]
#}
