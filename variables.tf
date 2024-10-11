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
  default     = "v4.10.3"
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
  nullable    = true
  default     = null
}

variable "licence_key" {
  description = "The Common Fate licence key."
  type        = string
  nullable    = true
  default     = null
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

variable "maintenance_mode_enabled" {
  description = "If 'true', the ALB will return a fixed response indicating that Common Fate is in maintenance mode."
  type        = bool
  default     = false
}

variable "maintenance_mode_message" {
  description = "The message to display when maintenance mode is enabled. This can be overridden to provide a custom maintenance message."
  type        = string
  default     = "Common Fate is currently down for maintenance. You can get in touch with us at support@commonfate.io."
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

variable "alert_metadata" {
  description = "Metadata to include in alerts emitted by Common Fate. Will be included in the 'metdata' field in the JSON alert payload."
  type        = any
  nullable    = true
  default     = null
}

variable "dynamodb_restore_date_time" {
  description = "Time of the point-in-time recovery point to restore."
  type        = string
  default     = null

}

variable "dynamodb_restore_source_name" {
  description = "Name of the table to restore. Must match the name of an existing table."
  type        = string
  default     = null

}
variable "dynamodb_restore_to_latest_time" {
  description = "If set, restores table to the most recent point-in-time recovery point."
  type        = bool
  default     = null
}

variable "rds_multi_az" {
  description = "Enables RDS database to be deployed across multiple Availability Zones"
  type        = bool
  default     = true
}

variable "rds_apply_immediately" {
  description = "Apply RDS changes immediately."
  type        = bool
  default     = true
}

variable "xray_monitoring_enabled" {
  description = "If enabled, writes OpenTelemetry monitoring events to AWS X-Ray."
  type        = bool
  default     = true
}

variable "usage_reporting_enabled" {
  description = "Enables usage reporting for the deployment."
  type        = bool
  default     = true
}

variable "usage_reporting_interval" {
  description = "The interval to report deployment usage on (e.g. '1h')."
  type        = string
  default     = "1h"
}

variable "managed_monitoring_enabled" {
  description = "Enables Managed Monitoring for the deployment."
  type        = bool
  default     = true
}

variable "managed_monitoring_endpoint" {
  description = "The Managed Monitoring OpenTelemetry endpoint"
  type        = string
  default     = "otel.commonfate.io"
}

variable "factory_base_url" {
  description = "The Common Fate Factory API Base URL"
  type        = string
  default     = "https://factory.commonfate.io"
}

variable "factory_oidc_issuer" {
  description = "The Common Fate Factory OIDC Issuer"
  type        = string
  default     = "https://factory.commonfate.io"
}

variable "centralised_support" {
  type        = bool
  default     = true
  description = "Enable the in-app centralised support feature."
}


variable "database_auto_migrate" {
  type        = bool
  default     = true
  description = "Whether to run database migrations automatically when the Control Plane service starts. If rolling back to a previous release after a migration has run, set this to `false`."
}

variable "cli_access_token_validity_duration" {
  description = "Specifies how long the access token in the CLI Cognito client will be valid for. Unit is specified in `web_oidc_token_validity_units` and is in minutes by default."
  default     = 60
  type        = number
}

variable "cli_refresh_token_validity_duration" {
  description = "Specifies how long the refresh token in the CLI Cognito client will be valid for.  Unit is specified in `web_oidc_token_validity_units` and is in days by default."
  default     = 30
  type        = number
}

variable "cli_access_token_validity_units" {
  description = "Specifies the duration unit used for the 'cli_access_token_validity_duration' variable. Valid values are seconds, minutes, hours or days."
  default     = "minutes"
}

variable "cli_refresh_token_validity_units" {
  description = "Specifies the duration unit used for the 'cli_refresh_token_validity_duration' variable. Valid values are seconds, minutes, hours or days."
  default     = "days"
}

variable "sync_entra_identities_enabled" {
  description = "Enables the Entra Identities Sync background task"
  type        = bool
  default     = true
}

variable "sync_okta_enabled" {
  description = "Enables the Okta Sync background task"
  type        = bool
  default     = true
}

variable "control_plane_ecs_task_memory" {
  description = "The amount of memory to allocate for the ECS task. Specified in MiB."
  type        = string
  default     = "1024"
}

variable "control_plane_ecs_task_cpu" {
  description = "The amount of CPU to allocate for the ECS task. Specified in CPU units (1024 units = 1 vCPU)."
  type        = string
  default     = "512"
}

variable "worker_ecs_task_memory" {
  description = "The amount of memory to allocate for the ECS task. Specified in MiB."
  type        = string
  default     = "1024"
}

variable "worker_ecs_task_cpu" {
  description = "The amount of CPU to allocate for the ECS task. Specified in CPU units (1024 units = 1 vCPU)."
  type        = string
  default     = "512"
}

variable "access_hander_ecs_task_memory" {
  description = "The amount of memory to allocate for the ECS task. Specified in MiB."
  type        = string
  default     = "1024"
}

variable "access_handler_ecs_task_cpu" {
  description = "The amount of CPU to allocate for the ECS task. Specified in CPU units (1024 units = 1 vCPU)."
  type        = string
  default     = "512"
}

variable "factory_monitoring" {
  description = "Enables ecs task reporting to Common Fate"
  type        = bool
  default     = true
}


variable "administrator_emails" {
  description = "List of user emails to assign the administrator role. Users will also be invited to the initial cognito user pool. The administrator role can also be assigned via the console. Note, users defined by this variable will always be assigned to the administrator role at startup of the control plane service."
  default     = []
  type        = list(string)
}
variable "rds_snapshot_identifier" {
  description = "(Optional) Specifies whether or not to create this database from a snapshot. This correlates to the snapshot ID you'd find in the RDS console, e.g: rds:production-2015-06-26-06-05."
  type        = string
  default     = null
}

variable "rds_instance_identifier_suffix" {
  description = "(Optional) adds a suffix to the database identifier"
  type        = string
  default     = ""

}
variable "web_target_group_arns" {
  description = "ARNs of supplemental target groups for the web service."
  default     = []
  type        = list(string)
}

variable "access_target_group_arns" {
  description = "ARNs of supplemental target groups for the access handler service."
  default     = []
  type        = list(string)
}

variable "control_plane_target_group_arns" {
  description = "ARNs of supplemental target groups for the control plane service."
  default     = []
  type        = list(string)
}

variable "managed_deployment" {
  description = "Whether this is a managed deployment, for new managed deployments, a default policy is added for access to the administrator role to assist with first time setup. You should not set this to true if you manage your own BYOC deployment."
  type        = bool
  default     = false
}


variable "compare_entitlements_enabled" {
  description = "Whether the compare entitlements background job is enabled"
  type        = bool
  default     = true
}

variable "iam_role_permission_boundary" {
  description = "If provided, attaches a Permission Boundary to all IAM roles in the module."
  type        = string
  nullable    = true
  default     = null
}
