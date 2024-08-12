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

variable "name_prefix" {
  description = "A unique identifier consisting of letters, numbers, and hyphens. can optionally be left empty when only deploying a signal instance of this module"
  type        = string
  default     = ""

  # validation {
  #   condition     = var.name_prefix != "" && can(regex("^[a-zA-Z0-9-]+$", var.name_prefix))
  #   error_message = "name_prefix should only contain letters, numbers, and hyphens"
  # }
}
variable "app_url" {
  description = "The app url (e.g., 'https://common-fate.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.app_url))
    error_message = "The app_url must start with 'https://'."
  }
}

variable "vpc_id" {
  description = "Specifies the ID of the VPC."
  type        = string
}

variable "subnet_ids" {
  description = "Lists the subnet IDs for deployment."
  type        = list(string)
}


variable "aws_region" {
  description = "Determines the AWS Region for deployment."
  type        = string
}
variable "aws_partition" {
  description = "The AWS partition the module is being deployed to"
}
variable "aws_account_id" {
  description = "Determines the AWS account ID for deployment."
  type        = string
}

variable "release_tag" {
  description = "Defines the tag for frontend and backend images, typically a git commit hash."
  type        = string
}


variable "ecs_cluster_id" {
  description = "Identifies the Amazon Elastic Container Service (ECS) cluster for deployment."
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
  default     = "256" # Example default, adjust as needed
}

variable "ecs_task_memory" {
  description = "The amount of memory to allocate for the ECS task. Specified in MiB."
  type        = string
  default     = "512" # Example default, adjust as needed
}
variable "desired_task_count" {
  description = "The desired number of instances of the task to run."
  type        = number
  default     = 1
}
variable "enable_verbose_logging" {
  description = "Enables debug level verbose logging on ecs tasks"
  type        = bool
  default     = false
}


variable "access_handler_sg_id" {
  description = "The Access Handler security group ID which will be allowed to make API calls to this provisioner."
  type        = string
}


variable "allow_ingress_from_sg_ids" {
  description = "The security group IDs which will be allowed to make API calls to this provisioner."
  type        = list(string)
  default     = []
}


variable "provisioner_service_client_id" {
  description = "Specifies the client ID for the provisioner service."
  type        = string
}

variable "provisioner_service_client_secret" {
  description = "Specifies the client secret for the provisioner service."
  type        = string
  sensitive   = true
}

variable "auth_issuer" {
  description = "Specifies the issuer for authentication."
  type        = string
}

variable "assume_role_external_id" {
  description = "(Optional) The external id to be used when assuming IAM roles"
  type        = string
  default     = ""
}


variable "provisioner_image_repository" {
  type        = string
  description = "Docker image repository to use for the Provisioner image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/provisioner"
}

variable "otel_log_group_name" {
  description = "Log group for OTel collector"
  type        = string
}
variable "otel_writer_iam_policy_arn" {
  description = "IAM policy for OpenTelemetry"
  type        = string
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
