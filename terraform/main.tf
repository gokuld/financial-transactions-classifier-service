terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

module "network" {
  source = "./modules/network"

  aws_region          = var.aws_region
  availability_zone_a = var.availability_zone_a
  availability_zone_b = var.availability_zone_b
}

module "data" {
  source = "./modules/data"

  aws_region                      = var.aws_region
  vpc_id                          = module.network.vpc_id
  s3_vpc_endpoint_route_table_ids = [module.network.private_route_table.id]
}
