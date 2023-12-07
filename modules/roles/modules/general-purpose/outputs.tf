######################################################
# Outputs
######################################################

output "read_role_arn" {
  description = "The read role arn"
  value       = aws_iam_role.read_role.arn
}

output "provision_role_arn" {
  description = "The provision role arn"
  value       = aws_iam_role.provision_role.arn
}

