######################################################
# Networking
######################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.1"

  name                         = "common_fate"
  cidr                         = "10.0.0.0/17"
  azs                          = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  public_subnets               = ["10.0.0.0/21", "10.0.8.0/21", "10.0.16.0/21"]
  private_subnets              = ["10.0.24.0/21", "10.0.32.0/21", "10.0.40.0/21"]
  database_subnets             = ["10.0.48.0/21", "10.0.56.0/21", "10.0.64.0/21"]
  create_database_subnet_group = true
  enable_dns_hostnames         = true
  enable_nat_gateway           = true
  single_nat_gateway           = var.single_nat_gateway
  one_nat_gateway_per_az       = var.one_nat_gateway_per_az
}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.s3"
  route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
}

resource "aws_vpc_endpoint" "dynamodb" {
  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${var.aws_region}.dynamodb"
  route_table_ids = flatten([module.vpc.intra_route_table_ids, module.vpc.private_route_table_ids, module.vpc.public_route_table_ids])
}
