######################################################
# Outputs
######################################################


output "authz_internal_address" {
  value = format("https://%s:%s", aws_ecs_service.authz_service.service_connect_configuration[0].service[0].discovery_name, aws_ecs_service.authz_service.service_connect_configuration[0].service[0].port_name)

}

