provider "aws" {
  alias  = "australia"
  region = var.australia_config.region
}

module "australia_network" {
  source = "./modules/network"

  region              = var.australia_config.region
  name                = var.australia_config.name
  vpc_cidr            = var.australia_config.vpc_cidr
  public_subnet_cidr  = var.australia_config.public_subnet_cidr
  private_subnet_cidr = var.australia_config.private_subnet_cidr
  tgw_id              = module.australia_tgw_branch.tgw_id
}

module "australia_frontend" {
  source = "./modules/frontend"

  region            = var.australia_config.region
  name              = var.australia_config.name
  vpc_id            = module.australia_network.vpc_id
  public_subnet_ids = module.australia_network.public_subnet_ids
  target_group_arn  = module.australia_backend.target_group_arn
}

module "australia_backend" {
  source = "./modules/backend"

  region                = var.australia_config.region
  name                  = var.australia_config.name
  vpc_id                = module.australia_network.vpc_id
  private_subnet_ids    = module.australia_network.private_subnet_ids
  frontend_sg_id        = module.australia_frontend.frontend_sg_id
  backend_instance_type = var.backend_config.backend_instance_type[0]
  desired_capacity      = var.backend_config.desired_capacity
  scaling_range         = var.backend_config.scaling_range
  user_data             = var.backend_config.user_data
}

module "australia_tgw_branch" {
  source = "./modules/tgw_branch"

  providers = {
    aws.default = aws.australia
    aws.tokyo   = aws.tokyo
  }

  region             = var.australia_config.region
  name               = var.australia_config.name
  vpc_id             = module.australia_network.vpc_id
  private_subnet_ids = module.australia_network.private_subnet_ids
  peer_tgw_id        = module.tgw_hq.tgw_id
  
}