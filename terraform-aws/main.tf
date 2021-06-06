module "networking" {
  source           = "./networking"
  vpc_cidr         = "10.123.0.0/16"
  security_groups  = local.security_groups
  private_sn_count = 3
  public_sn_count  = 3
  max_subnets      = 20
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  access_ip        = var.access_ip
  db_subnet_group  = true
}

module "database" {
  source                 = "./database"
  db_storage             = 10
  db_engine_version      = "5.7.22"
  db_instance_class      = "db.t2.micro"
  dbname                 = var.dbname
  dbuser                 = var.dbuser
  dbpassword             = var.dbpassword
  db_subnet_group_name   = ""
  vpc_security_group_ids = []
  db_identifier          = "kryz-db"
  skip_db_snapshot       = true
}

module "loadbalancing" {
  source                  = "./loadbalancing"
  public_sg               = module.networking.public_sg
  public_subnets          = module.networking.public_subnets
  lb_healthy_threeshold   = 2
  lb_unhealthy_threeshold = 2
  lb_timeout              = 3
  lb_interval             = 30
  tg_port                 = 80
  tg_protocol             = "HTTP"
  vpc_id                  = module.networking.vpc_id
  listener_port           = 80
  listener_protocol       = "HTTP"
}
