variable "project" {
  description = "The name of the project for which infrastructure is being provisioned."
  type        = string
}

variable "environment" {
  description = "The name of the environment for which infrastructure is being provisioned."
  type        = string
}

variable "db_username" {
  description = "The username used to authenticate with the PostgreSQL database."
  type        = string
  sensitive   = true
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

variable "rds_port" {
  description = "Port exposed by the RDS to redirect traffic to."
  type        = number
  default     = 5432
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "vpc_id" {
  type = string
}

variable "ecs_security_group_id" {
  type = string
}
