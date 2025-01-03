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

variable "vpc_id" {
  description = "Specifies the ID of the Virtual Private Cloud (VPC)."
  type        = string
}

variable "subnet_ids" {
  description = "Lists the IDs of the subnets."
  type        = list(string)
}

variable "release_tag" {
  description = "Defines the tag for frontend and backend images, typically a git commit hash."
  type        = string
}

variable "controlplane_api_url" {
  description = "The Control Plane API url (e.g., 'https://common-fate.mydomain.com')."
  type        = string
  nullable    = true
  default     = null
}

variable "access_api_url" {
  description = "The Access API url (e.g., 'https://common-fate.mydomain.com')."
  type        = string
  nullable    = true
  default     = null
}

variable "authz_api_url" {
  description = "The Authz API url (e.g., 'https://common-fate.mydomain.com')."
  type        = string
  nullable    = true
  default     = null
}

variable "app_url" {
  description = "The app url (e.g., 'https://common-fate.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.app_url))
    error_message = "The app_url must start with 'https://'."
  }
}

variable "aws_region" {
  description = "Determines the AWS Region for deployment."
  type        = string
}

variable "aws_account_id" {
  description = "Determines the AWS account ID for deployment."
  type        = string
}

variable "auth_url" {
  description = "Specifies the authentication domain (e.g., 'https://auth.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.auth_url))
    error_message = "The auth_url must start with 'https://'."
  }
}

variable "auth_authority_url" {
  description = "Specifies the URL used for authentication."
  type        = string
}

variable "auth_issuer" {
  description = "Specifies the issuer for authentication."
  type        = string
}
variable "auth_web_client_id" {
  description = "Specifies the client ID for web authentication."
  type        = string
}

variable "auth_cli_client_id" {
  description = "Specifies the client ID for CLI authentication."
  type        = string
}

variable "ecs_cluster_id" {
  description = "Identifies the Amazon Elastic Container Service (ECS) cluster for deployment."
  type        = string
}

variable "alb_listener_arn" {
  description = "Specifies the Amazon Load Balancer (ALB) listener ARN."
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

variable "alb_security_group_id" {
  type        = string
  description = "the ALB security group ID."
}

variable "alb_listener_rule_priority" {
  type        = number
  description = "Listener priority for the ALB rule to route traffic to the service."
  default     = 100
}

variable "web_image_repository" {
  type        = string
  description = "Docker image repository to use for the Web image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/web"
}
variable "centralised_support" {
  type        = bool
  default     = true
  description = "Enable the in-app centralised support feature."

}

variable "hierarchy_ui" {
  type        = bool
  default     = true
  description = "Enable new hierarchy tree view to select entitlements."

}

variable "web_target_group_arns" {
  type        = list(string)
  description = "Additional target groups to attach the service to."
  default     = []
}

variable "iam_role_permission_boundary" {
  description = "If provided, attaches a Permission Boundary to all IAM roles in the module."
  type        = string
  nullable    = true
  default     = null
}

variable "shell_session_logs_bucket_domain_name" {
  type        = string
  description = "Domain name of shell session logs bucket"
}
