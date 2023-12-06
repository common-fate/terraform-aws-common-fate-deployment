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

variable "web_domain" {
  description = "Specifies the frontend domain (e.g., 'https://mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.web_domain))
    error_message = "The web_domain must start with 'https://'."
  }
}

variable "control_plane_domain" {
  description = "Specifies the API domain (e.g., 'https://api.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.control_plane_domain))
    error_message = "The control_plane_domain must start with 'https://'."
  }
}
variable "access_handler_domain" {
  description = "Defines the domain for access handler (e.g., 'https://access.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.access_handler_domain))
    error_message = "The access_handler_domain must start with 'https://'."
  }
}
variable "aws_region" {
  description = "Determines the AWS Region for deployment."
  type        = string
}

variable "auth_domain" {
  description = "Specifies the authentication domain (e.g., 'https://auth.mydomain.com')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.auth_domain))
    error_message = "The auth_domain must start with 'https://'."
  }
}

variable "authz_url" {
  description = "Specifies the authz grpc api url (e.g., 'https://authz.mydomain.com/grpc')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.authz_url))
    error_message = "The authz_url must start with 'https://'."
  }
}

variable "authz_graph_url" {
  description = "Specifies the authz graphql api url (e.g., 'https://authz.mydomain.com/graph')."
  type        = string

  validation {
    condition     = can(regex("^https://", var.authz_graph_url))
    error_message = "The authz_graph_url must start with 'https://'."
  }
}

variable "team_name" {
  description = "Specifies the team name for branding the frontend."
  type        = string
}

variable "favicon_url" {
  description = "Specifies a public URL for the favicon used in frontend branding (e.g., 'https://commonfate.io/favicon.ico')."
  type        = string
}

variable "logo_url" {
  description = "Specifies a public URL for the logo used in frontend branding."
  type        = string
}

variable "auth_authority_url" {
  description = "Specifies the URL used for authentication."
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
