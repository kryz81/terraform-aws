variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "access_ip" {
  type = string
}

variable "dbuser" {
  type      = string
  sensitive = true
}

variable "dbname" {
  type = string
}

variable "dbpassword" {
  type      = string
  sensitive = true
}
