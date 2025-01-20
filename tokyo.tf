provider "aws" {
  alias  = "tokyo"
  region = var.tokyo_config.region
}

module "tokyo_network" {
  source = "./modules/network"

  region              = var.tokyo_config.region
  name                = var.tokyo_config.name
  vpc_cidr            = var.tokyo_config.vpc_cidr
  public_subnet_cidr  = var.tokyo_config.public_subnet_cidr
  private_subnet_cidr = var.tokyo_config.private_subnet_cidr
  tgw_id              = module.tgw_hq.tgw_id
}

module "tokyo_frontend" {
  source = "./modules/frontend"

  region            = var.tokyo_config.region
  name              = var.tokyo_config.name
  vpc_id            = module.tokyo_network.vpc_id
  public_subnet_ids = module.tokyo_network.public_subnet_ids
  target_group_arn  = module.tokyo_backend.target_group_arn
}

module "tokyo_backend" {
  source = "./modules/backend"

  region                = var.tokyo_config.region
  name                  = var.tokyo_config.name
  vpc_id                = module.tokyo_network.vpc_id
  private_subnet_ids    = module.tokyo_network.private_subnet_ids
  frontend_sg_id        = module.tokyo_frontend.frontend_sg_id
  backend_instance_type = var.backend_config.backend_instance_type[0]
  desired_capacity      = var.backend_config.desired_capacity
  scaling_range         = var.backend_config.scaling_range
  user_data             = var.backend_config.user_data
}

module "tgw_hq" {
  source = "./modules/tgw_hq"

  region             = var.tokyo_config.region
  vpc_id             = module.tokyo_network.vpc_id
  private_subnet_ids = module.tokyo_network.private_subnet_ids
}
#setup a centralized logging server
resource "aws_security_group" "tokyo_syslog_sg" {
  provider = aws.tokyo
  vpc_id   = module.tokyo_network.vpc_id

  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "syslog-sg"
  }
}

resource "aws_instance" "syslog_tokyo" {
  provider = aws.tokyo

  ami                    = "ami-08f52b2e87cebadd9"
  instance_type          = "t2.micro"
  subnet_id              = module.tokyo_network.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.tokyo_syslog_sg.id]
  user_data              = file("./scripts/syslogger.sh")
  tags = {
    Name = "syslog"
  }
}
output "tokyo_syslog_ip" {
  value = aws_instance.syslog_tokyo.private_ip
}
output "tokyo_syslog_region" {
  value = var.tokyo_config.region
}