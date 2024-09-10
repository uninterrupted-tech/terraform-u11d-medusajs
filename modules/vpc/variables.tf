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
