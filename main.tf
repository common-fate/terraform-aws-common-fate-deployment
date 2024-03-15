provider "aws" {
  region = var.aws_region
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}


module "vpc" {
  source                 = "./modules/vpc"
  namespace              = var.namespace
  stage                  = var.stage
  aws_region             = var.aws_region
  one_nat_gateway_per_az = var.one_nat_gateway_per_az
  single_nat_gateway     = var.single_nat_gateway
}

module "alb" {
  source    = "./modules/alb"
  namespace = var.namespace
  stage     = var.stage
  certificate_arns = [
    var.app_certificate_arn
  ]
  public_subnet_ids = module.vpc.public_subnet_ids
  vpc_id            = module.vpc.vpc_id
}

module "control_plane_db" {
  source              = "./modules/database"
  namespace           = var.namespace
  stage               = var.stage
  vpc_id              = module.vpc.vpc_id
  subnet_group_id     = module.vpc.database_subnet_group_id
  deletion_protection = var.database_deletion_protection
}

module "authz_db" {
  source    = "./modules/authz-database"
  namespace = var.namespace
  stage     = var.stage
}


module "events" {
  source    = "./modules/events"
  namespace = var.namespace
  stage     = var.stage
}

module "ecs" {
  source                                = "terraform-aws-modules/ecs/aws"
  version                               = "~> 4.1.3"
  cluster_name                          = "${var.namespace}-${var.stage}-cluster"
  default_capacity_provider_use_fargate = true
}

module "ecs_base" {
  source = "./modules/ecs-base"
}


module "cognito" {
  source                = "./modules/cognito"
  namespace             = var.namespace
  stage                 = var.stage
  aws_region            = var.aws_region
  app_url               = var.app_url
  auth_url              = var.auth_url
  auth_certificate_arn  = var.auth_certificate_arn
  saml_metadata_is_file = var.saml_metadata_is_file
  saml_metadata_source  = var.saml_metadata_source
  saml_provider_name    = var.saml_provider_name
  web_access_token_validity_duration = var.web_access_token_validity_duration
}



module "control_plane" {
  source    = "./modules/controlplane"
  namespace = var.namespace
  stage     = var.stage

  aws_region                                 = var.aws_region
  aws_account_id                             = data.aws_caller_identity.current.account_id
  aws_partition                              = data.aws_partition.current.id
  database_secret_sm_arn                     = module.control_plane_db.secret_arn
  database_security_group_id                 = module.control_plane_db.security_group_id
  eventbus_arn                               = module.events.event_bus_arn
  sqs_queue_arn                              = module.events.sqs_queue_arn
  app_url                                    = var.app_url
  pager_duty_client_id                       = var.pager_duty_client_id
  pager_duty_client_secret_ps_arn            = var.pager_duty_client_secret_ps_arn
  release_tag                                = var.release_tag
  scim_source                                = var.scim_source
  scim_token_ps_arn                          = var.scim_token_ps_arn
  slack_client_id                            = var.slack_client_id
  slack_client_secret_ps_arn                 = var.slack_client_secret_ps_arn
  slack_signing_secret_ps_arn                = var.slack_signing_secret_ps_arn
  subnet_ids                                 = module.vpc.private_subnet_ids
  vpc_id                                     = module.vpc.vpc_id
  ecs_cluster_id                             = module.ecs.cluster_id
  auth_authority_url                         = module.cognito.auth_authority_url
  database_host                              = module.control_plane_db.endpoint
  database_user                              = module.control_plane_db.username
  alb_listener_arn                           = module.alb.listener_arn
  sqs_queue_name                             = module.events.sqs_queue_name
  auth_issuer                                = module.cognito.auth_issuer
  control_plane_service_client_id            = module.cognito.control_plane_service_client_id
  control_plane_service_client_secret        = module.cognito.control_plane_service_client_secret
  licence_key_ps_arn                         = var.licence_key_ps_arn
  log_level                                  = var.control_plane_log_level
  grant_assume_on_role_arns                  = var.control_plane_grant_assume_on_role_arns
  oidc_control_plane_issuer                  = module.cognito.auth_issuer
  otel_log_group_name                        = module.ecs_base.otel_log_group_name
  otel_writer_iam_policy_arn                 = module.ecs_base.otel_writer_iam_policy_arn
  alb_security_group_id                      = module.alb.alb_security_group_id
  additional_cors_allowed_origins            = var.additional_cors_allowed_origins
  unstable_enable_feature_least_privilege    = var.unstable_enable_feature_least_privilege
  unstable_least_privilege_analysis_schedule = var.unstable_least_privilege_analysis_schedule
  unstable_sync_idc_cloudtrail_schedule      = var.unstable_sync_idc_cloudtrail_schedule
  report_bucket_arn                          = module.report_bucket.arn
  report_bucket_name                         = module.report_bucket.id
  assume_role_external_id                    = var.assume_role_external_id
}



module "report_bucket" {
  source         = "./modules/s3bucket"
  bucket_prefix  = "${var.namespace}-${var.stage}-reports"
  aws_account_id = data.aws_caller_identity.current.account_id
  region         = var.aws_region
  namespace      = var.namespace
  stage          = var.stage
  component      = "reports"
}


module "web" {
  source                                  = "./modules/web"
  namespace                               = var.namespace
  stage                                   = var.stage
  aws_region                              = var.aws_region
  release_tag                             = var.release_tag
  subnet_ids                              = module.vpc.private_subnet_ids
  vpc_id                                  = module.vpc.vpc_id
  auth_authority_url                      = module.cognito.auth_authority_url
  auth_cli_client_id                      = module.cognito.cli_client_id
  auth_url                                = module.cognito.auth_url
  auth_web_client_id                      = module.cognito.web_client_id
  logo_url                                = var.logo_url
  team_name                               = var.team_name
  ecs_cluster_id                          = module.ecs.cluster_id
  alb_listener_arn                        = module.alb.listener_arn
  app_url                                 = var.app_url
  auth_issuer                             = module.cognito.auth_issuer
  alb_security_group_id                   = module.alb.alb_security_group_id
  unstable_enable_feature_least_privilege = var.unstable_enable_feature_least_privilege
}

module "access_handler" {
  source                                    = "./modules/access"
  namespace                                 = var.namespace
  stage                                     = var.stage
  aws_region                                = var.aws_region
  eventbus_arn                              = module.events.event_bus_arn
  release_tag                               = var.release_tag
  subnet_ids                                = module.vpc.private_subnet_ids
  vpc_id                                    = module.vpc.vpc_id
  auth_authority_url                        = module.cognito.auth_authority_url
  ecs_cluster_id                            = module.ecs.cluster_id
  alb_listener_arn                          = module.alb.listener_arn
  auth_issuer                               = module.cognito.auth_issuer
  log_level                                 = var.access_handler_log_level
  app_url                                   = var.app_url
  oidc_access_handler_service_client_id     = module.cognito.access_handler_service_client_id
  oidc_access_handler_service_client_secret = module.cognito.access_handler_service_client_secret
  oidc_access_handler_service_issuer        = module.cognito.auth_issuer
  otel_log_group_name                       = module.ecs_base.otel_log_group_name
  otel_writer_iam_policy_arn                = module.ecs_base.otel_writer_iam_policy_arn
  alb_security_group_id                     = module.alb.alb_security_group_id
  additional_cors_allowed_origins           = var.additional_cors_allowed_origins
}

module "authz" {
  source                                = "./modules/authz"
  namespace                             = var.namespace
  stage                                 = var.stage
  aws_region                            = var.aws_region
  eventbus_arn                          = module.events.event_bus_arn
  release_tag                           = var.release_tag
  subnet_ids                            = module.vpc.private_subnet_ids
  vpc_id                                = module.vpc.vpc_id
  ecs_cluster_id                        = module.ecs.cluster_id
  alb_listener_arn                      = module.alb.listener_arn
  dynamodb_table_name                   = module.authz_db.dynamodb_table_name
  log_level                             = var.authz_log_level
  dynamodb_table_arn                    = module.authz_db.dynamodb_table_arn
  app_url                               = var.app_url
  oidc_trusted_issuer                   = module.cognito.auth_issuer
  oidc_terraform_client_id              = module.cognito.terraform_client_id
  oidc_access_handler_service_client_id = module.cognito.access_handler_service_client_id
  oidc_control_plane_client_id          = module.cognito.control_plane_service_client_id
  oidc_provisioner_service_client_id    = module.cognito.provisioner_client_id
  alb_security_group_id                 = module.alb.alb_security_group_id
  additional_cors_allowed_origins       = var.additional_cors_allowed_origins
}

module "provisioner" {
  source = "./modules/provisioner"
  // A name prefix is used so that this builtin provisioner may be deployed without causing downtime when migrating from an external provisioner deployment
  name_prefix                       = "builtin"
  namespace                         = var.namespace
  stage                             = var.stage
  aws_region                        = var.aws_region
  release_tag                       = var.release_tag
  access_handler_sg_id              = module.access_handler.security_group_id
  allow_ingress_from_sg_ids         = [module.control_plane.security_group_id]
  subnet_ids                        = module.vpc.private_subnet_ids
  vpc_id                            = module.vpc.vpc_id
  ecs_cluster_id                    = module.ecs.cluster_id
  provisioner_service_client_id     = module.cognito.provisioner_client_id
  provisioner_service_client_secret = module.cognito.provisioner_client_secret
  auth_issuer                       = module.cognito.auth_issuer
  app_url                           = var.app_url
  assume_role_external_id           = var.assume_role_external_id

  gcp_config      = var.provisioner_gcp_config
  aws_idc_config  = var.provisioner_aws_idc_config
  entra_config    = var.provisioner_entra_config
  aws_rds_config  = var.provisioner_aws_rds_config
  okta_config     = var.provisioner_okta_config
  datastax_config = var.provisioner_datastax_config

}
