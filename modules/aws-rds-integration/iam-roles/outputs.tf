######################################################
# Outputs
######################################################

output "rds_provisioning_role_name" {
  description = "The name of the rds provisioning role which is deployed in each target account"
  value       = local.role_name
}
