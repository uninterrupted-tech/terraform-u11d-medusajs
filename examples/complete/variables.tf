variable "region" {
  description = "AWS region"
  type        = string
  default     = "eu-west-1"
}

variable "project" {
  description = "Project name"
  type        = string
  default     = "medusa"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}
