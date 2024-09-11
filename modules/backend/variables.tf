variable "project" {
  description = "The name of the project for which infrastructure is being provisioned."
  type        = string
}

variable "environment" {
  description = "The name of the environment for which infrastructure is being provisioned."
  type        = string
}

variable "create" {
  description = "Enable resource creation"
  type        = bool
  default     = true
}

variable "listener_port" {
  description = "The port on which the ALB listens for incoming traffic."
  type        = number
  default     = 443
}

variable "medusa_image" {
  type = string
}

variable "app_count" {
  description = "Number of docker containers to run."
  type        = number
  default     = 1
}

variable "app_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)."
  type        = number
  default     = 2048
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to."
  type        = number
  default     = 9000
}

variable "app_memory" {
  description = "Fargate instance memory to provision (in MiB)."
  type        = number
  default     = 4096
}

variable "app_log_group" {
  description = "Name of the application log group in CloudWatch."
  type        = string
  default     = "/medusa"
}

variable "app_logs_retention" {
  description = "Log retention in days."
  type        = number
  default     = 30
}

variable "app_logs_prefix" {
  description = "Application logs prefix."
  type        = string
  default     = "container"
}

variable "medusa_run_migration" {
  description = "Specify medusa migrations should be run on start."
  type        = bool
  default     = true
}

variable "medusa_create_admin_user" {
  description = "Specify if database should be initilize with admin."
  type        = bool
  default     = true
}

variable "medusa_admin_username" {
  description = "The medusa admin username."
  type        = string
  sensitive   = true
}

variable "medusa_admin_password" {
  description = "The medusa admin password."
  type        = string
  sensitive   = true
}

variable "medusa_main_domain" {
  description = "Main domain of core and storefront."
  type        = string
}

variable "medusa_core_subdomain" {
  description = "The medusa core subdomain."
  type        = string
  default     = "api"
}

variable "ecr_arn" {
  description = "ARN of Elastic Container Registry."
  type        = string
  sensitive   = true
}

variable "certificate_arn" {
  type      = string
  sensitive = true
}

variable "vpc_id" {
  type = string
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_public_subnets" {
  type = list(string)
}

variable "elasticache_redis_url" {
  type = string
}

variable "elasticache_security_group_id" {
  type = string
}

variable "postgres_url" {
  type = string
}

variable "health_check_path" {
  description = "The path to monitor the health status of the service."
  type        = string
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required before considering a target healthy."
  type        = number
}

variable "health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks of an individual target."
  type        = number
}

variable "health_check_timeout" {
  description = "Amount of time, in seconds, during which no response from a target means a failed health check."
  type        = number
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy."
  type        = number
}

variable "health_check_matcher" {
  description = "The HTTP code to use when checking for a successful response from a target."
  type        = number
}
