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
  description = "Specifies the ID of the Virtual Private Cloud (VPC) for deployment."
  type        = string
}

variable "subnet_ids" {
  description = "Lists the IDs of the subnets for deployment."
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

variable "release_tag" {
  description = "Defines the tag for the frontend and backend images, typically a git commit hash."
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
  default     = "4096" # Example default, adjust as needed
}

variable "ecs_task_memory" {
  description = "The amount of memory to allocate for the ECS task. Specified in MiB."
  type        = string
  default     = "8192" # Example default, adjust as needed
}
variable "desired_task_count" {
  description = "The desired number of instances of the task to run."
  type        = number
  default     = 1
}
variable "dynamodb_table_name" {
  description = "The Dynamo DB table name"
  type        = string
}

variable "dynamodb_table_arn" {
  description = "The Dynamo DB table ARN"
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


variable "oidc_trusted_issuer" {
  description = "Trusted OIDC issuer to seed entities for"
  type        = string
}

variable "oidc_terraform_client_id" {
  description = "Terraform Service Account OIDC Client ID"
  type        = string
}

variable "oidc_control_plane_client_id" {
  description = "Control Plane Service Account OIDC Client ID"
  type        = string
}

variable "oidc_access_handler_service_client_id" {
  description = "Access Handler Service Account OIDC Client ID"
  type        = string
}

variable "log_level" {
  description = "Log level for ECS service"
  type        = string
  default     = "INFO"
}
