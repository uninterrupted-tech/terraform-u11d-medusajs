variable "create_vpc" {
  description = "Enable vpc creation"
  type        = bool
  default     = true
}

variable "create_elasticache" {
  type    = bool
  default = true
}

variable "create_rds" {
  type    = bool
  default = true
}

variable "create_backend" {
  description = "Enable backend resources creation"
  type        = bool
  default     = true
}

variable "create_storefront" {
  description = "Enable frontend resources creation"
  type        = bool
  default     = true
}

variable "project" {
  description = "The name of the project for which infrastructure is being provisioned."
  type        = string
}

variable "environment" {
  description = "The name of the environment for which infrastructure is being provisioned."
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block used in VPC"
  type        = string
  default     = "172.16.0.0/16"
}

variable "az_count" {
  description = "Number of AZs to cover in a given region."
  type        = number
  default     = 2
}

variable "listener_port" {
  description = "The port on which the ALB listens for incoming traffic."
  type        = number
  default     = 443
}

variable "medusa_image" {
  description = "Image tag of the docker image to run in the ECS cluster."
  type        = string
}

variable "ecr_arn" {
  description = "ARN of Elastic Container Registry."
  type        = string
  sensitive   = true
}

variable "certificate_arn" {
  description = "ARN of the default SSL server certificate."
  type        = string
  sensitive   = true
  default     = ""
}

variable "medusa_storefront_code_repository_arn" {
  description = "ARN of the Medusa Strorefront code repository."
  type        = string
}

variable "medusa_storefront_code_repository_url" {
  description = "The url of Medusa Storefront code repository."
  type        = string
}

variable "medusa_core_subdomain" {
  description = "The medusa core subdomain."
  type        = string
  default     = "api"
}

variable "medusa_main_domain" {
  description = "Medusa main domain of core and storefront."
  type        = string
}

variable "medusa_storefront_subdomain" {
  description = "The medusa storefront subdomain."
  type        = string
  default     = "store"
}

variable "route53_evaluate_target_health" {
  description = "Specify if you want Route 53 to determine whether to respond to DNS queries using this resource record set by checking the health of the resource record set."
  type        = string
  default     = true
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

variable "app_count" {
  description = "Number of docker containers to run."
  type        = number
  default     = 1
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

variable "health_check_path" {
  description = "The path to monitor the health status of the service."
  type        = string
  default     = "/health"
}

variable "health_check_healthy_threshold" {
  description = "Number of consecutive health check successes required before considering a target healthy."
  type        = number
  default     = 3
}

variable "health_check_interval" {
  description = "Approximate amount of time, in seconds, between health checks of an individual target."
  type        = number
  default     = 30
}

variable "health_check_timeout" {
  description = "Amount of time, in seconds, during which no response from a target means a failed health check."
  type        = number
  default     = 3
}

variable "health_check_unhealthy_threshold" {
  description = "Number of consecutive health check failures required before considering a target unhealthy."
  type        = number
  default     = 3
}

variable "health_check_matcher" {
  description = "The HTTP code to use when checking for a successful response from a target."
  type        = number
  default     = 200
}

variable "rds_port" {
  description = "Port exposed by the RDS to redirect traffic to."
  type        = number
  default     = 5432
}

variable "db_username" {
  description = "The username used to authenticate with the PostgreSQL database."
  type        = string
  sensitive   = true
  default     = "medusa"
}

variable "db_allocated_storage" {
  description = "The allocated storage in gibibytes."
  type        = number
  default     = 5
}

variable "db_engine_version" {
  description = "The postgres engine version to use. You can provide a prefix of the version such as 8.0 (for 8.0.36)."
  type        = string
  default     = "15.6"
}

variable "db_instance_class" {
  description = "The instance type of the RDS instance."
  type        = string
  default     = "db.t3.micro"
}

variable "redis_engine_version" {
  description = "The version of the redis that will be used to create the Elasticache cluster. You can provide a prefix of the version such as 7.1 (for 7.1.4)."
  type        = string
  default     = "7.1"
}

variable "elasticache_node_type" {
  description = "The Elasticache instance class used."
  type        = string
  default     = "cache.t3.micro"
}

variable "elasticache_nodes_num" {
  description = "The initial number of cache nodes that the cache cluster will have."
  type        = number
  default     = 1
}

variable "elasticache_port" {
  description = "Port exposed by the redis to redirect traffic to."
  type        = number
  default     = 6379
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

variable "medusa_admin_email" {
  description = "The medusa admin email."
  type        = string
  sensitive   = true
}

variable "medusa_admin_password" {
  description = "The medusa admin password."
  type        = string
  sensitive   = true
}

variable "github_access_token" {
  description = "Github access token."
  type        = string
  sensitive   = true
}
