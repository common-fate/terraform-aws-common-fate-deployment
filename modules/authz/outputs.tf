######################################################
# Outputs
######################################################

output "graphql_api_url" {
  description = "The GraphQL API URL."
  value       = var.authz_domain + "/graph"
}

output "grpc_api_url" {
  description = "The GRPC API URL."
  value       = var.authz_domain + "/grpc"
}
