######################################################
# Outputs
######################################################

output "vpc_id" {
  description = "The ID of the Virtual Private Cloud (VPC) created by the VPC module."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids" {
  description = "The IDs of the public subnets created by the VPC module."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "The IDs of the private subnets created by the VPC module."
  value       = module.vpc.private_subnets
}

output "database_subnet_group_id" {
  description = "The ID of the database subnet group created by the VPC module."
  value       = module.vpc.database_subnet_group
}
