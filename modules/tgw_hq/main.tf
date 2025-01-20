provider "aws" {
  region = var.region
}

resource "aws_ec2_transit_gateway" "tokyo" {

  description = "Tokyo Transit Gateway"
  tags = {
    Name = "tokyo-transit-gateway"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "tokyo" {

  transit_gateway_id = aws_ec2_transit_gateway.tokyo.id
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids
}

data "aws_caller_identity" "tokyo" {}


#########tgw route table##########

/* data "aws_ec2_transit_gateway_route_table" "tokyo" {
  provider = aws.tokyo

  filter {
    name   = "default-association-route-table"
    values = ["true"]
  }

  filter {
    name   = "transit-gateway-id"
    values = [aws_ec2_transit_gateway.tokyo.id]
  }

  tags = {
    Name = "tgw-rtb-${var.tokyo_config.name}"
  }

  depends_on = [aws_ec2_transit_gateway.tokyo]
} */

# resource "aws_ec2_transit_gateway_route" "to_new_york" {
#   provider                       = aws.tokyo
#   destination_cidr_block         = var.new_york_config.vpc_cidr
#   transit_gateway_route_table_id = data.aws_ec2_transit_gateway_route_table.tokyo.id
#   transit_gateway_attachment_id  = ""
# }

# resource "aws_ec2_transit_gateway_peering_attachment" "tokyo_to_new_york" {
#   provider                = aws.tokyo
#   peer_region             = var.new_york_config.region
#   peer_transit_gateway_id = ""
#   transit_gateway_id      = aws_ec2_transit_gateway.tokyo.id
#   tags = {
#     Name = "$[var.tokyo_config.name}-to-$[var.new_york_config.name]"
#   }
# }
