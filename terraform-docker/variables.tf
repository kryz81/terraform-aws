#variable "env" {
#  type = string
#}

variable "image" {
  type = map(map(string))
  default = {
    nodered = {
      dev  = "nodered/node-red:latest"
      prod = "nodered/node-red:latest-minimal"
    },
    influxdb = {
      dev  = "quay.io/influxdb/influxdb:v2.0.2"
      prod = "quay.io/influxdb/influxdb:v2.0.2"
    }
  }
}

variable "ext_port" {
  type = map(any)

  #validation {
  #  condition     = min(var.ext_port["dev"]...) >= 4000 && max(var.ext_port["dev"]...) <= 4002
  #  error_message = "External port must be 3000 or higher."
  #}

  #validation {
  #  condition     = min(var.ext_port["prod"]...) >= 3000 && max(var.ext_port["prod"]...) <= 3002
  #  error_message = "External port must be 3000 or higher."
  #}
}

variable "int_port" {
  type = map(number)

  #  validation {
  #    condition     = tonumber(var.int_port) == 1880
  #    error_message = "Internal port must be 1880."
  #  }
}

locals {
  #container_count = length(lookup(var.ext_port, terraform.workspace))
}
