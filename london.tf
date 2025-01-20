provider "aws" {
  alias  = "london"
  region = var.london_config.region
}

module "london_network" {
  source = "./modules/network"

  region              = var.london_config.region
  name                = var.london_config.name
  vpc_cidr            = var.london_config.vpc_cidr
  public_subnet_cidr  = var.london_config.public_subnet_cidr
  private_subnet_cidr = var.london_config.private_subnet_cidr
  tgw_id              = module.london_tgw_branch.tgw_id
}

module "london_frontend" {
  source = "./modules/frontend"

  region            = var.london_config.region
  name              = var.london_config.name
  vpc_id            = module.london_network.vpc_id
  public_subnet_ids = module.london_network.public_subnet_ids
  target_group_arn  = module.london_backend.target_group_arn
}

module "london_backend" {
  source = "./modules/backend"

  region                = var.london_config.region
  name                  = var.london_config.name
  vpc_id                = module.london_network.vpc_id
  private_subnet_ids    = module.london_network.private_subnet_ids
  frontend_sg_id        = module.london_frontend.frontend_sg_id
  backend_instance_type = var.backend_config.backend_instance_type[0]
  desired_capacity      = var.backend_config.desired_capacity
  scaling_range         = var.backend_config.scaling_range
  user_data             = var.backend_config.user_data
}

module "london_tgw_branch" {
  source = "./modules/tgw_branch"

  providers = {
    aws.default = aws.london
    aws.tokyo   = aws.tokyo
  }

  region             = var.london_config.region
  name               = var.london_config.name
  vpc_id             = module.london_network.vpc_id
  private_subnet_ids = module.london_network.private_subnet_ids
  peer_tgw_id        = module.tgw_hq.tgw_id
}