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

variable "proxy_service_client_id" {
  description = "Specifies the client ID for the  proxy service."
  type        = string
}

variable "proxy_service_client_secret" {
  description = "Specifies the client secret for the  proxy service."
  type        = string
  sensitive   = true
}

variable "auth_issuer" {
  description = "Specifies the issuer for authentication."
  type        = string
}

variable "proxy_image_repository" {
  type        = string
  description = "Docker image repository to use for the Provisioner image"
  default     = "public.ecr.aws/z2x0a3a1/common-fate-deployment/proxy"
}


variable "integration_id" {
  description = "The ID of the integration in Common Fate."
  type        = string
}
variable "databases" {
  description = "List of databases"
  type = list(object({
    // the  instance id
    instance_id = string
    // the endpoint for the  instance
    endpoint = string
    // the name for the AWS::::Database resource
    name = string
    // the name of the database on the instance
    database = string
    // the engine of the database on the instance, mysql or postgres
    engine = string

    users = list(object({
      // the name for the AWS::::DatabaseUser resource
      name = string
      // the username to connect to the database with
      username = string
      // the ARN of the password in secrets manager for this user
      passwordSecretsManagerARN = string
    }))
  }))

}
variable "ecs_cluster_read_role_arn" {
  description = "The ARN of the IAM role which grants your Common Fate Provisioner read access to the ECS cluster containing this proxy."
  type        = string
}
