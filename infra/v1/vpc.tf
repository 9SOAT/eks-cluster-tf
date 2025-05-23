
data "aws_availability_zones" "available" {
  state = "available"
}

module "eks-vpc" {
  source = "terraform-aws-modules/vpc/aws"
  version = "5.17.0"

  name = "${var.projectName}-vpc"
  cidr = var.cidr_block

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = [cidrsubnet(var.cidr_block, 8, 110), cidrsubnet(var.cidr_block, 8, 120)]
  public_subnets  = [cidrsubnet(var.cidr_block, 8, 10), cidrsubnet(var.cidr_block, 8, 20)]
  database_subnets = [cidrsubnet(var.cidr_block, 8, 130), cidrsubnet(var.cidr_block, 8, 140)]

  create_database_subnet_group           = true
  database_subnet_group_name             = "fast-food-database-subnet-group"
  database_subnet_tags             = { Test: "fast-food-database-subnet" }
  create_database_subnet_route_table     = true
  create_database_internet_gateway_route = true


  enable_dns_support   = true

  create_igw = true # Default is true

  enable_dns_hostnames = true # Default is true

  # nat_gateway configuration
  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  create_private_nat_gateway_route = true # Default is true

  tags = var.tags
}
