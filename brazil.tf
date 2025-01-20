provider "aws" {
  alias  = "brazil"
  region = var.brazil_config.region
}

module "brazil_network" {
  source = "./modules/network"

  region              = var.brazil_config.region
  name                = var.brazil_config.name
  vpc_cidr            = var.brazil_config.vpc_cidr
  public_subnet_cidr  = var.brazil_config.public_subnet_cidr
  private_subnet_cidr = var.brazil_config.private_subnet_cidr
  tgw_id              = module.brazil_tgw_branch.tgw_id
}

module "brazil_frontend" {
  source = "./modules/frontend"

  region            = var.brazil_config.region
  name              = var.brazil_config.name
  vpc_id            = module.brazil_network.vpc_id
  public_subnet_ids = module.brazil_network.public_subnet_ids
  target_group_arn  = module.brazil_backend.target_group_arn
}

module "brazil_backend" {
  source = "./modules/backend"

  region                = var.brazil_config.region
  name                  = var.brazil_config.name
  vpc_id                = module.brazil_network.vpc_id
  private_subnet_ids    = module.brazil_network.private_subnet_ids
  frontend_sg_id        = module.brazil_frontend.frontend_sg_id
  backend_instance_type = var.backend_config.backend_instance_type[1]
  desired_capacity      = var.backend_config.desired_capacity
  scaling_range         = var.backend_config.scaling_range
  user_data             = var.backend_config.user_data
}

module "brazil_tgw_branch" {
  source = "./modules/tgw_branch"

  providers = {
    aws.default = aws.brazil
    aws.tokyo   = aws.tokyo
  }

  region             = var.brazil_config.region
  name               = var.brazil_config.name
  vpc_id             = module.brazil_network.vpc_id
  private_subnet_ids = module.brazil_network.private_subnet_ids
  peer_tgw_id        = module.tgw_hq.tgw_id
}