variable "namespace" {
  description = "Specifies the namespace for the deployment."
  default     = "common-fate"
  type        = string
}

variable "stage" {
  description = "Determines the deployment stage (e.g., 'dev', 'staging', 'prod')."
  default     = "prod"
  type        = string
}

variable "vpc_id" {
  description = "Specifies the ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "Lists the subnet IDs for deployment."
  type        = list(string)
}

variable "eventbus_arn" {
  description = "Specifies the Amazon EventBridge (formerly CloudWatch Events) EventBus ARN."
  type        = string
}

variable "aws_region" {
  description = "Determines the AWS Region for deployment."
  type        = string
}

variable "aws_account_id" {
  description = "Determines the AWS account ID for deployment."
  type        = string
}

variable "release_tag" {
  description = "Defines the tag for frontend and backend images, typically a git commit hash."
  type        = string
}
variable "app_url" {
  description = "The app url (e.g., 'https://common-fate.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.app_url))
    error_message = "The app_url must start with 'https://'."
  }
}


variable "ecs_cluster_id" {
  description = "Identifies the Amazon Elastic Container Service (ECS) cluster for deployment."
  type        = string
}

variable "alb_listener_arn" {
  description = "Specifies the Amazon Load Balancer (ALB) listener ARN."
  type        = string
}

variable "auth_issuer" {
  description = "Specifies the issuer for authentication."
  type        = string
}

variable "log_retention_in_days" {
  description = "Specifies the cloudwatch log retention period."
  default     = 365
  type        = number
}
variable "ecs_task_cpu" {
  description = "The amount of CPU to allocate for the ECS task. Specified in CPU units (1024 units = 1 vCPU)."
  type        = string
  default     = "512"
}

variable "ecs_task_memory" {
  description = "The amount of memory to allocate for the ECS task. Specified in MiB."
  type        = string
  default     = "1024"
}
variable "desired_task_count" {
  description = "The desired number of instances of the task to run."
  type        = number
  default     = 1
}

variable "log_level" {
  description = "Log level for ECS service"
  type        = string
  default     = "INFO"
}

variable "oidc_access_handler_service_client_id" {
  description = "OIDC client ID for the Access Handler Service"
  type        = string
}

variable "oidc_access_handler_service_client_secret" {
  description = "OIDC client secret for the Access Handler Service"
  type        = string
}

variable "oidc_access_handler_service_issuer" {
  description = "OIDC issuer for the Access Handler Service"
  type        = string
}

variable "otel_log_group_name" {
  description = "Log group for OTel collector"
  type        = string
}

variable "otel_writer_iam_policy_arn" {
  description = "IAM policy for OpenTelemetry"
  type        = string
}
variable "alb_security_group_id" {
  type        = string
  description = "the security group id for the outward facing alb"
}

variable "additional_cors_allowed_origins" {
  type        = list(string)
  default     = []
  description = "Additional origins to add to the CORS allowlist. By default, the app URL is automatically added."
}

variable "access_image_repository" {
  type        = string
  description = "Docker image repository to use for the Access image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/access"
}


variable "service_discovery_namespace_arn" {
  type        = string
  description = "namespace arn of service discovery namespace"
}


variable "worker_security_group_id" {
  type        = string
  description = "The id of the security group for the worker."
}


variable "control_plane_security_group_id" {
  type        = string
  description = "The id of the security group for the control plane."
}


variable "database_security_group_id" {
  description = "Specifies the ID of the security group for the database."
  type        = string
}

variable "database_secret_sm_arn" {
  description = "The AWS Secrets Manager ARN for the database credentials."
  type        = string
}

variable "database_user" {
  description = "Specifies the username for database access."
  type        = string
}

variable "database_host" {
  description = "Specifies the hostname or IP address of the database."
  type        = string
}

variable "authz_eval_bucket_name" {
  type        = string
  description = "Name of authorization evaluation bucket"
}
variable "authz_eval_bucket_arn" {
  type        = string
  description = "ARN of authorization evaluation bucket"
}


variable "licence_key" {
  description = "The Common Fate licence key."
  type        = string
}

variable "xray_monitoring_enabled" {
  description = "If enabled, writes OpenTelemetry monitoring events to AWS X-Ray."
  type        = bool
  default     = true
}

variable "managed_monitoring_enabled" {
  description = "Enables Managed Monitoring for the deployment."
  type        = bool
  default     = false
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


variable "factory_monitoring" {
  description = "Enables ecs task reporting to Common Fate"
  type        = bool
  default     = true
}

variable "access_target_group_arns" {
  type        = list(string)
  description = "Additional target groups to attach the service to."
  default     = []
}

variable "builtin_provisioner_url" {
  description = "The URL of the builtin provisioner."
  type        = string
}

variable "iam_role_permission_boundary" {
  description = "If provided, attaches a Permission Boundary to all IAM roles in the module."
  type        = string
  nullable    = true
  default     = null
}
