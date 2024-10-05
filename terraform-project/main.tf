provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source             = "/home/mohab/modules/vpc"
  cidr_block         = var.vpc_cidr_block
  public_cidr_block  = var.public_cidr_block
  private_cidr_block = var.private_cidr_block
}

module "instances" {
  source            = "/home/mohab/modules/instances"
  instance_type     = var.instance_type
  public_subnet_id  = module.vpc.public_subnet_id
  private_subnet_id = module.vpc.private_subnet_id
}

module "load_balancer" {
  source             = "/home/mohab/modules/load_balancer"
  availability_zones = var.availability_zones
  instance_ids       = [module.instances.proxy_id]
}
