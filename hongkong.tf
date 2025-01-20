provider "aws" {
  alias  = "hong_kong"
  region = var.hong_kong_config.region
}

module "hong_kong_network" {
  source = "./modules/network"

  region              = var.hong_kong_config.region
  name                = var.hong_kong_config.name
  vpc_cidr            = var.hong_kong_config.vpc_cidr
  public_subnet_cidr  = var.hong_kong_config.public_subnet_cidr
  private_subnet_cidr = var.hong_kong_config.private_subnet_cidr
  tgw_id              = module.hong_kong_tgw_branch.tgw_id
}

module "hong_kong_frontend" {
  source = "./modules/frontend"

  region            = var.hong_kong_config.region
  name              = var.hong_kong_config.name
  vpc_id            = module.hong_kong_network.vpc_id
  public_subnet_ids = module.hong_kong_network.public_subnet_ids
  target_group_arn  = module.hong_kong_backend.target_group_arn
}

module "hong_kong_backend" {
  source = "./modules/backend"

  region                = var.hong_kong_config.region
  name                  = var.hong_kong_config.name
  vpc_id                = module.hong_kong_network.vpc_id
  private_subnet_ids    = module.hong_kong_network.private_subnet_ids
  frontend_sg_id        = module.hong_kong_frontend.frontend_sg_id
  backend_instance_type = var.backend_config.backend_instance_type[1]
  desired_capacity      = var.backend_config.desired_capacity
  scaling_range         = var.backend_config.scaling_range
  user_data             = var.backend_config.user_data
}

module "hong_kong_tgw_branch" {
  source = "./modules/tgw_branch"

  providers = {
    aws.default = aws.hong_kong
    aws.tokyo   = aws.tokyo
  }

  region             = var.hong_kong_config.region
  name               = var.hong_kong_config.name
  vpc_id             = module.hong_kong_network.vpc_id
  private_subnet_ids = module.hong_kong_network.private_subnet_ids
  peer_tgw_id        = module.tgw_hq.tgw_id
}