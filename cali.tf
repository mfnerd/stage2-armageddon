provider "aws" {
  alias  = "cali"
  region = var.cali_config.region
}

module "cali_network" {
  source = "./modules/network"

  region              = var.cali_config.region
  name                = var.cali_config.name
  vpc_cidr            = var.cali_config.vpc_cidr
  public_subnet_cidr  = var.cali_config.public_subnet_cidr
  private_subnet_cidr = var.cali_config.private_subnet_cidr
  tgw_id              = module.cali_tgw_branch.tgw_id
}

module "cali_frontend" {
  source = "./modules/frontend"

  region            = var.cali_config.region
  name              = var.cali_config.name
  vpc_id            = module.cali_network.vpc_id
  public_subnet_ids = module.cali_network.public_subnet_ids
  target_group_arn  = module.cali_backend.target_group_arn
}

module "cali_backend" {
  source = "./modules/backend"

  region                = var.cali_config.region
  name                  = var.cali_config.name
  vpc_id                = module.cali_network.vpc_id
  private_subnet_ids    = module.cali_network.private_subnet_ids
  frontend_sg_id        = module.cali_frontend.frontend_sg_id
  backend_instance_type = var.backend_config.backend_instance_type[0]
  desired_capacity      = var.backend_config.desired_capacity
  scaling_range         = var.backend_config.scaling_range
  user_data             = var.backend_config.user_data
}

module "cali_tgw_branch" {
  source = "./modules/tgw_branch"

  providers = {
    aws.default = aws.cali
    aws.tokyo   = aws.tokyo
  }

  region             = var.cali_config.region
  name               = var.cali_config.name
  vpc_id             = module.cali_network.vpc_id
  private_subnet_ids = module.cali_network.private_subnet_ids
  peer_tgw_id        = module.tgw_hq.tgw_id
}