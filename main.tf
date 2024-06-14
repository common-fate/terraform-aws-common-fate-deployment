provider "aws" {
  region = var.aws_region
}

data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}

locals {
  vpc_id                   = var.vpc_id != null ? var.vpc_id : module.vpc[0].vpc_id
  public_subnet_ids        = var.vpc_id != null ? var.public_subnet_ids : module.vpc[0].public_subnet_ids
  private_subnet_ids       = var.vpc_id != null ? var.private_subnet_ids : module.vpc[0].private_subnet_ids
  database_subnet_group_id = var.vpc_id != null ? var.database_subnet_group_id : module.vpc[0].database_subnet_group_id
  ecs_cluster_id           = var.ecs_cluster_id != null ? var.ecs_cluster_id : module.ecs[0].cluster_id
}

moved {
  from = module.vpc
  to   = module.vpc[0]
}

locals {
  licence_key_value = var.licence_key_ps_arn != null ? data.aws_ssm_parameter.licence_key[0].value : var.licence_key
}

data "aws_arn" "licence_key" {
  count = var.licence_key_ps_arn != null ? 1 : 0
  arn   = var.licence_key_ps_arn
}

data "aws_ssm_parameter" "licence_key" {
  count = var.licence_key_ps_arn != null ? 1 : 0
  // the parameter resource is e.g. 'parameter/common-fate/prod/licence-key',
  // but we need '/common-fate/prod/licence-key' here.
  name = trimprefix(data.aws_arn.licence_key[0].resource, "parameter")
}

module "vpc" {
  count                  = var.vpc_id != null ? 0 : 1
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
  public_subnet_ids          = local.public_subnet_ids
  vpc_id                     = local.vpc_id
  use_internal_load_balancer = var.use_internal_load_balancer
}

module "control_plane_db" {
  source                   = "./modules/database"
  namespace                = var.namespace
  stage                    = var.stage
  vpc_id                   = local.vpc_id
  subnet_group_id          = local.database_subnet_group_id
  deletion_protection      = var.database_deletion_protection
  rds_db_retention_period  = var.rds_db_retention_period
  restore_to_point_in_time = var.restore_to_point_in_time
  rds_multi_az             = var.rds_multi_az
  apply_immediately        = var.rds_apply_immediately
}


module "authz_db" {
  source                          = "./modules/authz-database"
  namespace                       = var.namespace
  stage                           = var.stage
  dynamodb_restore_date_time      = var.dynamodb_restore_date_time
  dynamodb_restore_source_name    = var.dynamodb_restore_source_name
  dynamodb_restore_to_latest_time = var.dynamodb_restore_to_latest_time
}


module "events" {
  source    = "./modules/events"
  namespace = var.namespace
  stage     = var.stage
}


module "alerts" {
  source         = "./modules/alerts"
  namespace      = var.namespace
  stage          = var.stage
  aws_account_id = data.aws_caller_identity.current.account_id
  ecs_cluster_id = local.ecs_cluster_id
  aws_region     = var.aws_region
  alert_metadata = var.alert_metadata
  event_bus_name = module.events.event_bus_name
}



moved {
  from = module.ecs
  to   = module.ecs[0]
}

moved {
  from = module.authz.aws_cloudwatch_log_group.authz_log_group
  to   = module.authz-legacy.aws_cloudwatch_log_group.authz_log_group
}

module "ecs" {
  count                                 = var.ecs_cluster_id != null ? 0 : 1
  source                                = "terraform-aws-modules/ecs/aws"
  version                               = "~> 4.1.3"
  cluster_name                          = "${var.namespace}-${var.stage}-cluster"
  default_capacity_provider_use_fargate = true
}

module "ecs_base" {
  source                = "./modules/ecs-base"
  namespace             = var.namespace
  stage                 = var.stage
  log_retention_in_days = var.ecs_opentelemetry_collector_log_retention_in_days
}


module "cognito" {
  source                              = "./modules/cognito"
  namespace                           = var.namespace
  stage                               = var.stage
  aws_region                          = var.aws_region
  app_url                             = var.app_url
  auth_url                            = var.auth_url
  auth_certificate_arn                = var.auth_certificate_arn
  saml_metadata_is_file               = var.saml_metadata_is_file
  saml_metadata_source                = var.saml_metadata_source
  saml_provider_name                  = var.saml_provider_name
  web_access_token_validity_duration  = var.web_access_token_validity_duration
  web_access_token_validity_units     = var.web_access_token_validity_units
  web_refresh_token_validity_duration = var.web_refresh_token_validity_duration
  web_refresh_token_validity_units    = var.web_refresh_token_validity_units
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
  release_tag                                = var.release_tag
  scim_source                                = var.scim_source
  scim_token_ps_arn                          = var.scim_token_ps_arn
  subnet_ids                                 = local.private_subnet_ids
  vpc_id                                     = local.vpc_id
  ecs_cluster_id                             = local.ecs_cluster_id
  database_host                              = module.control_plane_db.endpoint
  database_user                              = module.control_plane_db.username
  alb_listener_arn                           = module.alb.listener_arn
  sqs_queue_name                             = module.events.sqs_queue_name
  auth_issuer                                = module.cognito.auth_issuer
  control_plane_service_client_id            = module.cognito.control_plane_service_client_id
  control_plane_service_client_secret        = module.cognito.control_plane_service_client_secret
  slack_service_client_id                    = module.cognito.slack_service_client_id
  slack_service_client_secret                = module.cognito.slack_service_client_secret
  oidc_slack_issuer                          = module.cognito.auth_issuer
  licence_key                                = local.licence_key_value
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
  authz_eval_bucket_name                     = module.authz_eval_bucket.id
  authz_eval_bucket_arn                      = module.authz_eval_bucket.arn
  control_image_repository                   = var.control_image_repository
  worker_image_repository                    = var.worker_image_repository
  service_discovery_namespace_arn            = module.ecs_base.service_discovery_namespace_arn
  access_handler_security_group_id           = module.access_handler.security_group_id
  access_handler_service_connect_address     = module.access_handler.access_handler_internal_address
  xray_monitoring_enabled                    = var.xray_monitoring_enabled
  managed_monitoring_enabled                 = var.managed_monitoring_enabled
  managed_monitoring_endpoint                = var.managed_monitoring_endpoint
  factory_base_url                           = var.factory_base_url
  factory_oidc_issuer                        = var.factory_oidc_issuer
  unstable_feature_embedded_authorizations   = var.unstable_feature_embedded_authorizations
  force_rerun_config_migrations              = var.force_rerun_config_migrations
  database_auto_migrate                      = var.database_auto_migrate
  oidc_access_handler_service_client_id      = module.cognito.access_handler_service_client_id
  oidc_provisioner_service_client_id         = module.cognito.provisioner_client_id
  oidc_terraform_client_id                   = module.cognito.terraform_client_id
  oidc_read_only_client_id                   = module.cognito.read_only_client_id
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

module "authz_eval_bucket" {
  source         = "./modules/s3bucket"
  bucket_prefix  = "${var.namespace}-${var.stage}-evals"
  aws_account_id = data.aws_caller_identity.current.account_id
  region         = var.aws_region
  namespace      = var.namespace
  stage          = var.stage
  component      = "evals"
}


module "web" {
  source                = "./modules/web"
  namespace             = var.namespace
  stage                 = var.stage
  aws_region            = var.aws_region
  aws_account_id        = data.aws_caller_identity.current.account_id
  release_tag           = var.release_tag
  subnet_ids            = local.private_subnet_ids
  vpc_id                = local.vpc_id
  auth_authority_url    = module.cognito.auth_authority_url
  auth_cli_client_id    = module.cognito.cli_client_id
  auth_url              = module.cognito.auth_url
  auth_web_client_id    = module.cognito.web_client_id
  logo_url              = var.logo_url
  team_name             = var.team_name
  ecs_cluster_id        = local.ecs_cluster_id
  alb_listener_arn      = module.alb.listener_arn
  app_url               = var.app_url
  auth_issuer           = module.cognito.auth_issuer
  alb_security_group_id = module.alb.alb_security_group_id
  web_image_repository  = var.web_image_repository
  centralised_support   = var.centralised_support
  hierarchy_ui          = var.hierarchy_ui
}


module "access_handler" {
  source                                    = "./modules/access"
  namespace                                 = var.namespace
  stage                                     = var.stage
  aws_region                                = var.aws_region
  aws_account_id                            = data.aws_caller_identity.current.account_id
  eventbus_arn                              = module.events.event_bus_arn
  release_tag                               = var.release_tag
  subnet_ids                                = local.private_subnet_ids
  vpc_id                                    = local.vpc_id
  ecs_cluster_id                            = local.ecs_cluster_id
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
  access_image_repository                   = var.access_image_repository
  service_discovery_namespace_arn           = module.ecs_base.service_discovery_namespace_arn
  control_plane_security_group_id           = module.control_plane.security_group_id
  worker_security_group_id                  = module.control_plane.worker_security_group_id
  database_secret_sm_arn                    = module.control_plane_db.secret_arn
  database_security_group_id                = module.control_plane_db.security_group_id
  database_host                             = module.control_plane_db.endpoint
  database_user                             = module.control_plane_db.username
  authz_eval_bucket_arn                     = module.authz_eval_bucket.arn
  authz_eval_bucket_name                    = module.authz_eval_bucket.id
  licence_key                               = local.licence_key_value
  xray_monitoring_enabled                   = var.xray_monitoring_enabled
  managed_monitoring_enabled                = var.managed_monitoring_enabled
  managed_monitoring_endpoint               = var.managed_monitoring_endpoint
  factory_base_url                          = var.factory_base_url
  factory_oidc_issuer                       = var.factory_oidc_issuer
  unstable_feature_embedded_authorizations  = var.unstable_feature_embedded_authorizations
}


module "provisioner" {
  source = "./modules/provisioner"
  // A name prefix is used so that this builtin provisioner may be deployed without causing downtime when migrating from an external provisioner deployment
  name_prefix                       = "builtin"
  namespace                         = var.namespace
  stage                             = var.stage
  aws_region                        = var.aws_region
  aws_account_id                    = data.aws_caller_identity.current.account_id
  release_tag                       = var.release_tag
  access_handler_sg_id              = module.access_handler.security_group_id
  allow_ingress_from_sg_ids         = [module.control_plane.security_group_id]
  subnet_ids                        = local.private_subnet_ids
  vpc_id                            = local.vpc_id
  ecs_cluster_id                    = local.ecs_cluster_id
  provisioner_service_client_id     = module.cognito.provisioner_client_id
  provisioner_service_client_secret = module.cognito.provisioner_client_secret
  auth_issuer                       = module.cognito.auth_issuer
  app_url                           = var.app_url
  assume_role_external_id           = var.assume_role_external_id
  provisioner_image_repository      = var.provisioner_image_repository
  aws_partition                     = data.aws_partition.current.id
  otel_log_group_name               = module.ecs_base.otel_log_group_name
  otel_writer_iam_policy_arn        = module.ecs_base.otel_writer_iam_policy_arn
  licence_key                       = local.licence_key_value
  xray_monitoring_enabled           = var.xray_monitoring_enabled
  managed_monitoring_enabled        = var.managed_monitoring_enabled
  managed_monitoring_endpoint       = var.managed_monitoring_endpoint
  factory_base_url                  = var.factory_base_url
  factory_oidc_issuer               = var.factory_oidc_issuer

}

module "authz-legacy" {
  source    = "./modules/authz-legacy"
  namespace = var.namespace
  stage     = var.stage
}


