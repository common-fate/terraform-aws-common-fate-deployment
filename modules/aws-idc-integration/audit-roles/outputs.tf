######################################################
# Outputs
######################################################

output "audit_role_name" {
  description = "The name of the audit role which is deployed in each target account"
  value       = local.role_name
}
