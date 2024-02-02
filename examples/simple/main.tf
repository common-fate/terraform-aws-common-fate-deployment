module "common-fate" {
  source                                  = "common-fate/common-fate-deployment/aws"
  version                                 = "1.0.0"
  namespace                               = var.namespace
  auth_certificate_arn                    = var.auth_certificate_arn
  aws_region                              = var.aws_region
  licence_key_ps_arn                      = var.licence_key_ps_arn
  logo_url                                = var.logo_url
  pager_duty_client_id                    = var.pager_duty_client_id
  pager_duty_client_secret_ps_arn         = var.pager_duty_client_secret_ps_arn
  release_tag                             = var.release_tag
  saml_metadata_is_file                   = var.saml_metadata_is_file
  saml_metadata_source                    = var.saml_metadata_source
  saml_provider_name                      = var.saml_provider_name
  scim_token_ps_arn                       = var.scim_token_ps_arn
  slack_client_id                         = var.slack_client_id
  slack_client_secret_ps_arn              = var.slack_client_secret_ps_arn
  slack_signing_secret_ps_arn             = var.slack_signing_secret_ps_arn
  stage                                   = var.stage
  team_name                               = var.team_name
  app_url                                 = var.app_url
  app_certificate_arn                     = var.app_certificate_arn
  enable_verbose_logging                  = true
  auth_url                                = var.auth_url
  control_plane_grant_assume_on_role_arns = []
  scim_source                             = var.scim_source

}
