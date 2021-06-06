locals {
  vpc_cidr = "10.123.0.0/16"
}

locals {
  security_groups = {
    public = {
      name        = "public_sg"
      description = "Public SG"
      ingress = {
        ssh = {
          from        = 22
          to          = 22
          protocol    = "TCP"
          cidr_blocks = [var.access_ip]
        }
        http = {
          from        = 80
          to          = 80
          protocol    = "TPC"
          cidr_blocks = ["0.0.0.0/0"]
        }

      }
    }
    rds = {
      name        = "rds_sg"
      description = "RDS SG"
      ingress = {
        mysql = {
          from        = 3306
          to          = 3306
          protocol    = "TCP"
          cidr_blocks = [local.vpc_cidr]
        }
      }
    }
  }
}
