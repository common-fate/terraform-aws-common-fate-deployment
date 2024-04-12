######################################################
# Outputs
######################################################


output "authz_internal_address" {
  value = format("http://%s:%s", aws_ecs_service.authz_service.service_connect_configuration[0].service[0].client_alias[0].dns_name, aws_ecs_service.authz_service.service_connect_configuration[0].service[0].client_alias[0].port)

}

