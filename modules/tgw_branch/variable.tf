variable "region" {
  description = "region where the transit gateway will be created"
  type        = string
}

variable "name" {
  description = "name of the transit gateway"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to associate with the transit gateway"
  type        = string
}

variable "private_subnet_ids" {
  description = "Subnet IDs to associate with the transit gateway"
  type        = list(string)
}

variable "peer_tgw_id" {
  description = "Peer Transit Gateway ID"
  type        = string
}

