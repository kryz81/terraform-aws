resource "random_string" "myrandom" {
  count = var.count_in
  #for_each = local.deployment
  #count   = local.container_count
  length  = 6
  special = false
  upper   = false
}

resource "docker_container" "nodered_container" {
  count = var.count_in
  image = var.image_in
  name  = join("-", [var.name_in, terraform.workspace, random_string.myrandom[count.index].result])
  ports {
    internal = var.int_port_in[count.index]
    external = var.ext_port_in
  }
  volumes {
    container_path = var.vol_container_path
    volume_name    = docker_volume.container_volume[count.index].name
  }
}

resource "docker_volume" "container_volume" {
  count = var.count_in
  name = "${var.name_in}-volume-${count.index}"
  lifecycle {
    prevent_destroy = false
  }
  provisioner "local-exec" {
    when = destroy
    command = "mkdir ${path.cwd}/../backup"
    on_failure = continue
  }

  provisioner "local-exec" {
    when = destroy
    command = "sudo tar -czvf ${path.cwd}/../backup/${self.name}.tar.gz ${self.mountpoint}/"
    on_failure = fail
  }
}
