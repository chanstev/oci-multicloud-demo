# Prerequisites: Create a VPC with a Workload Subnet for the ODB Peering Connection
module "vpc" {
  source     = "aws-ia/vpc/aws"
  version    = "4.5.0"
  tags       = local.tags
  name       = local.name.vpc
  azs        = [local.location.az_name]
  cidr_block = local.app_network.vpc_cidr
  subnets = {
    workload = { 
      cidrs = [local.app_network.workload_subnet_cidr]
    }
  }
}