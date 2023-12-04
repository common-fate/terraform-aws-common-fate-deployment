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
  single_nat_gateway           = false
  one_nat_gateway_per_az       = true
}
