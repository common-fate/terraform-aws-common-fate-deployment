variable "namespace" {
  description = "Specifies the namespace for the deployment."
  default     = "common-fate"
  type        = string
}

variable "stage" {
  description = "Defines the stage of the deployment (e.g., 'dev', 'staging', 'prod')."
  default     = "prod"
  type        = string
}

variable "aws_region" {
  description = "Determines the AWS Region for the deployment."
  type        = string
}

variable "release_tag" {
  description = "Override the application release tag to be used in the deployment. As of module version v1.13.0, application versions are bundled into the Terraform module, and so in most cases you should not override this."
  type        = string
  default     = "v3.8.1"
}

variable "app_certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the application."
  type        = string
}

variable "auth_certificate_arn" {
  description = "The Amazon Certificate Manager (ACM) certificate ARN for the auth domain. Must be provisioned in us-east-1 for CloudFront. Provide this and the auth_url to configure cognito with a custom domain."
  type        = string
  default     = ""
}

variable "pager_duty_client_id" {
  description = "The private Pager Duty application client ID."
  default     = ""
  type        = string
}

variable "pager_duty_client_secret_ps_arn" {
  description = "The AWS Parameter Store ARN for the private Pager Duty application client secret."
  default     = ""
  type        = string
}

variable "slack_client_id" {
  description = "The private Slack application client ID."
  default     = ""
  type        = string
}

variable "slack_client_secret_ps_arn" {
  description = "The AWS Parameter Store ARN for the private Slack application client secret."
  default     = ""
  type        = string
}

variable "slack_signing_secret_ps_arn" {
  description = "The AWS Parameter Store ARN for the private Slack application signing secret."
  default     = ""
  type        = string
}



variable "auth_url" {
  description = "The custom auth url (e.g., 'https://auth.mydomain.com'). Provide this and the auth_certificate_arn to configure cognito with a custom domain."
  type        = string
  default     = ""
}

variable "app_url" {
  description = "The app url (e.g., 'https://common-fate.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.app_url))
    error_message = "The app_url must start with 'https://'."
  }
}

variable "team_name" {
  description = "Specifies the team name used for branding on the frontend."
  default     = "Common Fate"
  type        = string
}



variable "logo_url" {
  description = "Specifies a public logo URL for frontend branding."
  default     = ""
  type        = string
}

variable "saml_provider_name" {
  description = "The name of the identity provider (e.g., 'Entra') displayed on the login screen."
  default     = ""
  type        = string
}


variable "scim_source" {
  description = "The name of the SCIM identity provider (e.g., 'Entra')"
  default     = ""
  type        = string
}


variable "saml_metadata_is_file" {
  description = "Determines if the 'saml_metadata_source' is a file path or a URL. Set to true for a file, false for a URL."
  default     = false
  type        = bool
}

variable "saml_metadata_source" {
  description = "Specifies the URL or file path for the SAML metadata."
  default     = ""
  type        = string
}

variable "scim_token_ps_arn" {
  description = "The AWS Parameter Store ARN for the SCIM token."
  default     = ""
  type        = string
}

variable "licence_key_ps_arn" {
  description = "The AWS Parameter Store ARN for the license key."
  type        = string
}



variable "access_handler_log_level" {
  description = "Log level for Access Handler service"
  type        = string
  default     = "INFO"
}


variable "control_plane_log_level" {
  description = "Log level for Control Plane service"
  type        = string
  default     = "INFO"
}

variable "authz_log_level" {
  description = "Log level for Authz service"
  type        = string
  default     = "INFO"
}

variable "additional_cors_allowed_origins" {
  type        = list(string)
  default     = []
  description = "Additional origins to add to the CORS allowlist. By default, the app URL is automatically added."
}

variable "ecs_opentelemetry_collector_log_retention_in_days" {
  description = "Specifies the retention period for the ECS OpenTelemetry Collector CloudWatch Log Group."
  default     = 365
  type        = number
}


variable "provisioner_aws_idc_config" {
  description = <<EOF
  Configuration for AWS IDC. The following keys are expected:
  - role_arn: The ARN of the IAM role for the provisioner to assume which hass permissions to provision access in an AWS organization.
  - idc_region: The AWS IDC Region.
  - idc_instance_arn: The AWS Identity Center instance ARN.
  - idc_identity_store_id: The AWS IAM Identity Center Identity Store ID.
  EOF
  type = object({
    role_arn              = string
    idc_region            = string
    idc_instance_arn      = string
    idc_identity_store_id = string
  })
  default = null
}

variable "provisioner_gcp_config" {
  description = <<EOF
  Configuration for GCP. The following keys are expected:
  - service_account_client_json_ps_arn: (Optional) when using service account credentials, this is ARN of the secret credentials.
  - workload_identity_config_json: (Optional) using Workload Identity Federation, this is the config file.

  Either `workload_identity_config_json` or `service_account_client_json_ps_arn` must be provided (not both).
  EOF
  type = object({
    service_account_client_json_ps_arn = optional(string)
    workload_identity_config_json      = optional(string)
  })
  default = null
}


variable "provisioner_entra_config" {
  description = <<EOF
  Configuration for GCP. The following keys are expected:
  - tenant_id: The Entra tenant ID.
  - client_id: The client ID for the Entra App Registration.
  - client_secret_secret_path: The SSM Parameter store secret path for the client secret for the Entra App Registration.
  EOF
  type = object({
    tenant_id                 = string
    client_id                 = string
    client_secret_secret_path = string
  })
  default = null
}


variable "provisioner_aws_rds_config" {
  description = <<EOF
  Configuration for AWS RDS. The following keys are expected:
  - idc_role_arn: The ARN of the IAM role for the provisioner to assume which hass permissions to provision access in an AWS organization.
  - idc_region: The AWS IDC Region.
  - idc_instance_arn: The AWS Identity Center instance ARN.
  - infra_role_name: The name of the IAM role which is deployed each each account containing databases.
  - should_provision_security_groups: (Optional) Whether or not the provisioner should attempt to provision security groups. Set this to true if you are not using pre deployed security groups.
  EOF
  type = object({
    idc_role_arn                     = string
    idc_region                       = string
    idc_instance_arn                 = string
    infra_role_name                  = string
    should_provision_security_groups = optional(bool)
  })
  default = null
}

variable "provisioner_okta_config" {
  description = <<EOF
  Configuration for Okta. The following keys are expected:
  - organization_id: The ID of your Okta organization.
  - api_key_secret_path: The SSM Parameter store secret path for the api key for the Okta organization.
  EOF
  type = object({
    organization_id     = string
    api_key_secret_path = string
  })
  default = null
}


variable "provisioner_datastax_config" {
  description = <<EOF
  Configuration for DataStax. The following keys are expected:
  - api_key_secret_path: The SSM Parameter store secret path for the api key for the DataStax organization.
  EOF
  type = object({
    api_key_secret_path = string
  })
  default = null
}



variable "unstable_enable_feature_least_privilege" {
  type        = bool
  default     = false
  description = "Opt-in to enable Least Privilege Analytics (in early access). This variable will be removed once the feature is released."
}

variable "unstable_sync_idc_cloudtrail_schedule" {
  type        = string
  default     = "13 0 * * *"
  description = "Least Privilege Analytics: the schedule to sync AWS CloudTrail events on"
}

variable "unstable_least_privilege_analysis_schedule" {
  type        = string
  default     = "13 5 * * *"
  description = "Least Privilege Analytics: the schedule to build least privilege reports on"
}

variable "assume_role_external_id" {
  type        = string
  nullable    = true
  description = "External ID to use when assuming cross-account AWS roles for auditing and provisioning."
  default     = null
}

variable "control_plane_grant_assume_on_role_arns" {
  description = "(Deprecated) The ARNs of the IAM roles which the controlplane should be able to assume."
  type        = list(string)
  default     = []
}

variable "single_nat_gateway" {
  default     = false
  description = "Should be true if you want to provision a single shared NAT Gateway for the deployment."
}


variable "one_nat_gateway_per_az" {
  default     = true
  description = "Should be false if you want to provision a single shared NAT Gateway for the deployment."
}

variable "database_deletion_protection" {
  description = "Enables deletion protection for the RDS database. For production deployments this should be set to 'true'."
  default     = true
  type        = bool
}

variable "vpc_id" {
  description = "For BYO VPC deployments: specifies the ID of the Virtual Private Cloud (VPC) for deployment."
  type        = string
  default     = null
  nullable    = true
}


variable "database_subnet_group_id" {
  description = "For BYO VPC deployments: specifies the ID of the database subnet group for deployment."
  type        = string
  default     = null
  nullable    = true
}

variable "public_subnet_ids" {
  description = "For BYO VPC deployments: specifies the IDs of the VPC public subnets."
  type        = list(string)
  default     = null
  nullable    = true
}

variable "private_subnet_ids" {
  description = "For BYO VPC deployments: specifies the IDs of the VPC private subnets."
  type        = list(string)
  default     = null
  nullable    = true
}

variable "ecs_cluster_id" {
  description = "For BYO VPC deployments: specifies the ID of an existing ECS cluster to deploy to."
  type        = string
  default     = null
  nullable    = true
}

variable "use_internal_load_balancer" {
  description = "If 'true', the provisioned load balancer will be internal rather than external. Use this when you want to restrict network access to Common Fate to be behind a VPN only."
  default     = false
}
variable "web_access_token_validity_duration" {
  description = "Specifies how long the access token in the web cognito client will be valid for. Unit is in minutes"
  default     = 10
  type        = number
}

variable "web_refresh_token_validity_duration" {
  description = "Specifies how long the refresh token in the web cognito client will be valid for.  Unit is specified in `web_oidc_token_validity_units` and is in days by default."
  default     = 30
  type        = number
}

variable "web_access_token_validity_units" {
  description = "Specifies the duration unit used for the 'web_access_token_validity_duration' variable. Valid values are seconds, minutes, hours or days."
  default     = "minutes"
}

variable "web_refresh_token_validity_units" {
  description = "Specifies the duration unit used for the 'web_access_token_validity_duration' variable. Valid values are seconds, minutes, hours or days."
  default     = "days"
}

variable "worker_image_repository" {
  type        = string
  description = "Docker image repository to use for the Worker image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/worker"
}

variable "control_image_repository" {
  type        = string
  description = "Docker image repository to use for the Control image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/control"
}

variable "access_image_repository" {
  type        = string
  description = "Docker image repository to use for the Access image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/access"
}

variable "authz_image_repository" {
  type        = string
  description = "Docker image repository to use for the Authz image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/authz"
}

variable "provisioner_image_repository" {
  type        = string
  description = "Docker image repository to use for the Provisioner image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/provisioner"
}

variable "web_image_repository" {
  type        = string
  description = "Docker image repository to use for the Web image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/web"
}





variable "rds_db_retention_period" {
  description = "The backup retention period for the RDS instance"
  type        = number
  default     = 7
}


variable "restore_to_point_in_time" {
  description = "Configuration block for restoring a DB instance to an arbitrary point in time"
  type = object(
    {
      restore_time                             = string
      source_db_instance_identifier            = string
      source_dbi_resource_id                   = string
      use_latest_restorable_time               = bool
      source_db_instance_automated_backups_arn = string
    }
  )
  default = null
}
variable "unstable_enable_feature_access_simulation" {
  type        = bool
  default     = false
  description = "Opt-in to enable Access Simulation APIs (in early access). This variable will be removed once the feature is released."
}

variable "alerts" {
  description = "Configure alerts emitted by Common Fate"
  type = object({
    all_deployment_events = bool
  })

  default = {
    all_deployment_events = false
  }
}
