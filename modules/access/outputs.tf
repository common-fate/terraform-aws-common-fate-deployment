######################################################
# Outputs
######################################################

output "security_group_id" {
  value = aws_security_group.ecs_access_handler_sg_v2.id
}


output "access_handler_internal_address" {
  value = format("http://%s:%s", aws_ecs_service.access_handler_service.service_connect_configuration[0].service[0].client_alias[0].dns_name, aws_ecs_service.access_handler_service.service_connect_configuration[0].service[0].client_alias[0].port)

}



