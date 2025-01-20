provider "aws" {
  alias  = "osaka"
  region = var.osaka_config.region
}

module "osaka_network" {
  source = "./modules/network"

  region                     = var.osaka_config.region
  name                       = var.osaka_config.name
  vpc_cidr                   = var.osaka_config.vpc_cidr
  public_subnet_cidr         = var.osaka_config.public_subnet_cidr
  private_subnet_cidr        = var.osaka_config.private_subnet_cidr
  database_subnet_cidr       = var.osaka_config.database_subnet_cidr
  tgw_id                     = module.osaka_tgw_branch.tgw_id
  number_of_database_subnets = 2
  number_of_private_subnets  = 2
  number_of_public_subnets   = 1
}

# module "osaka_frontend" {
#   source = "./modules/frontend"

#   region            = var.osaka_config.region
#   name              = var.osaka_config.name
#   vpc_id            = module.osaka_network.vpc_id
#   public_subnet_ids = module.osaka_network.public_subnet_ids
#   target_group_arn  = module.osaka_backend.target_group_arn
# }

# module "syslog" {
#   source = "./modules/syslog"

#   # region                = var.osaka_config.region
#   # name                  = var.osaka_config.name
#   # vpc_id                = module.osaka_network.vpc_id
#   # private_subnet_ids    = module.osaka_network.private_subnet_ids
#   # syslog_sg_id        = module.syslog.syslog_sg_id
#   # # syslog_instance_type = var.osaka_config.syslog_instance_type
#   # user_data             = var.osaka_config.user_data
# }

module "osaka_tgw_branch" {
  source = "./modules/tgw_branch"

  providers = {
    aws.default = aws.osaka
    aws.tokyo   = aws.tokyo
  }

  region = var.osaka_config.region
  name   = var.osaka_config.name
  vpc_id = module.osaka_network.vpc_id

  private_subnet_ids = module.osaka_network.private_subnet_ids
  peer_tgw_id        = module.tgw_hq.tgw_id
}


resource "aws_rds_cluster" "aurora_osaka" {
  provider           = aws.osaka
  cluster_identifier = "aurora-cluster-demo"
  engine             = "aurora-mysql"
  engine_version     = "8.0.mysql_aurora.3.05.2"
  # availability_zones      = ["us-west-2a", "us-west-2b", "us-west-2c"]
  database_name          = "mydb"
  master_username        = "foo"
  master_password        = "must_be_eight_characters"
  storage_encrypted      = false
  skip_final_snapshot    = true
  db_subnet_group_name   = module.osaka_network.db_subnet_group
  vpc_security_group_ids = [aws_security_group.database_sg.id]
}

resource "aws_rds_cluster_instance" "aurora_osaka_instance" {
  provider             = aws.osaka
  cluster_identifier   = aws_rds_cluster.default.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.default.engine
  engine_version       = aws_rds_cluster.default.engine_version
  publicly_accessible  = false
  db_subnet_group_name = module.osaka_network.db_subnet_group
  force_destroy        = true

}

resource "aws_security_group" "database_sg" {
  provider = aws.osaka
  vpc_id   = module.osaka_network.vpc_id
  ingress {
    from_port   = 3306
    to_port     = 3306
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
    Name = "database-sg"
  }
}
output "osaka_rds_cluster_location" {
  value = var.osaka_config.region
}
#Create a security group for syslog server
resource "aws_security_group" "osaka_syslog_sg" {
  provider = aws.osaka
  vpc_id   = module.osaka_network.vpc_id
  ingress {
    from_port   = 514
    to_port     = 514
    protocol    = "udp"
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
resource "aws_instance" "syslog_osaka" {
  provider       = aws.osaka
  ami            = "ami-00dda9c6b6a1e5d93"
  instance_type  = "t2.micro"
  subnet_id      = module.osaka_network.private_subnet_ids[0]
  vpc_security_group_ids = [aws_security_group.osaka_syslog_sg.id]
  tags = {
    Name = "syslog-osaka"
  }
  user_data = file("./scripts/syslogger.sh")
}

output "osaka_syslog_ip" {
  value = aws_instance.syslog_osaka.private_ip
}
output "osaka_syslog_region" {
  value = var.osaka_config.region
}