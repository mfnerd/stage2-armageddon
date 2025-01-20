variable "region" {
  description = "The region in which to create the network"
  type        = string
}

variable "name" {
  description = "The name of the environment"
  type        = string
}

variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
}

variable "public_subnet_cidr" {
  description = "The CIDR blocks for the public subnets"
  type        = list(string)
}

variable "private_subnet_cidr" {
  description = "The CIDR blocks for the private subnets"
  type        = list(string)
}

variable "database_subnet_cidr" {
  description = "The CIDR blocks for the database subnets"
  type        = list(string)
  default     = []
}

variable "number_of_public_subnets" {
  description = "The number of public subnets"
  type        = number
  default     = 2
}

variable "number_of_private_subnets" {
  description = "The number of private subnets"
  type        = number
  default     = 2
}

variable "number_of_database_subnets" {
  description = "The number of database subnets"
  type        = number
  default     = 0
}

variable "tgw_id" {
  description = "Transit Gateway ID"
  type        = string
}

