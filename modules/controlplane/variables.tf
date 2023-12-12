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

variable "sqs_queue_arn" {
  description = "Specifies the Amazon Simple Queue Service (SQS) queue ARN."
  type        = string
}

variable "sqs_queue_name" {
  description = "Specifies the name of the Amazon SQS queue."
  type        = string
}

variable "eventbus_arn" {
  description = "Specifies the Amazon EventBridge (formerly CloudWatch Events) EventBus ARN."
  type        = string
}

variable "release_tag" {
  description = "Defines the tag for frontend and backend images, typically a git commit hash."
  type        = string
}

variable "pager_duty_client_id" {
  description = "Specifies the private Pager Duty application client ID."
  type        = string
}

variable "pager_duty_client_secret_ps_arn" {
  description = "The AWS Parameter Store ARN for the Pager Duty app client secret."
  default     = ""
  type        = string
}

variable "slack_client_id" {
  description = "Specifies the private Slack application client ID."
  type        = string
}

variable "slack_client_secret_ps_arn" {
  description = "The AWS Parameter Store ARN for the Slack application client secret."
  default     = ""
  type        = string
}

variable "slack_signing_secret_ps_arn" {
  description = "The AWS Parameter Store ARN for the Slack application signing secret."
  default     = ""
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


variable "scim_token_ps_arn" {
  description = "The AWS Parameter Store ARN for the SCIM token."
  default     = ""
  type        = string
}

variable "aws_region" {
  description = "Determines the AWS Region for deployment."
  type        = string
}

variable "ecs_cluster_id" {
  description = "Identifies the Amazon Elastic Container Service (ECS) cluster for deployment."
  type        = string
}

variable "auth_authority_url" {
  description = "Specifies the URL used for authentication."
  type        = string
}

variable "auth_issuer" {
  description = "Specifies the issuer for authentication."
  type        = string
}

variable "control_plane_service_client_id" {
  description = "Specifies the client ID for the control_plane service."
  type        = string
}

variable "control_plane_service_client_secret" {
  description = "Specifies the client secret for the control_plane service."
  type        = string
  sensitive   = true
}

variable "oidc_control_plane_issuer" {
  description = "OIDC issuer for the Control Plane service"
  type        = string
}

variable "alb_listener_arn" {
  description = "Specifies the Amazon Load Balancer (ALB) listener ARN."
  type        = string
}
variable "licence_key_ps_arn" {
  description = "The AWS Parameter Store ARN for the license key."
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
variable "grant_assume_on_role_arns" {
  description = "The ARNs of the IAM roles which the controlplane should be able to assume."
  type        = list(string)
  default     = []
}
variable "scim_source" {
  description = "The name of the SCIM identity provider (e.g., 'Entra')"
  default     = ""
  type        = string
}
variable "aws_partition" {
  description = "The AWS partition the module is being deployed to"
}

variable "aws_account_id" {
  description = "The AWS account ID the module is being deployed to"
}
