#data "docker_registry_image" "nodered" {
#  name = lookup(var.image, terraform.workspace)
#}

locals {
  deployment = {
    nodered = {
      container_count = length(var.ext_port["nodered"][terraform.workspace])
      image          = var.image["nodered"][terraform.workspace]
      int            = var.int_port["nodered"]
      ext            = var.ext_port["nodered"][terraform.workspace]
      container_path = "/data"
      host_path      = "${path.cwd}/noderedvol-"
    }
    influxdb = {
      container_count = length(var.ext_port["influxdb"][terraform.workspace])
      image          = var.image["influxdb"][terraform.workspace]
      int            = var.int_port["influxdb"]
      ext            = var.ext_port["influxdb"][terraform.workspace]
      container_path = "/var/lib/influxdb"
      host_path      = "${path.cwd}/influxdb-"
    }
  }
}

module "image" {
  source   = "./image"
  for_each = local.deployment
  image_in = each.value.image
}

module "container" {
  source   = "./container"
  for_each = local.deployment
  count_in = each.value.container_count
  #count              = local.container_count
  image_in           = module.image["nodered"].image_out
  name_in            = each.key
  int_port_in        = each.value.int
  ext_port_in        = each.value.ext
  vol_container_path = each.value.container_path
  vol_host_path      = "${each.value.host_path}${each.key}"

  #depends_on = [null_resource.docker_volume]
}


#resource "null_resource" "docker_volume" {
#  count = local.container_count
#
#  provisioner "local-exec" {
#    command = "mkdir noderedvol-${count.index}/ || true && sudo chown -R 1000:1000 noderedvol-${count.index}/"
#  }
#}
