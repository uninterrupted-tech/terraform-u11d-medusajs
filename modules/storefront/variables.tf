variable "project" {
  description = "The name of the project for which infrastructure is being provisioned."
  type        = string
}

variable "environment" {
  description = "The name of the environment for which infrastructure is being provisioned."
  type        = string
}

variable "medusa_storefront_code_repository_arn" {
  description = "ARN of the Medusa Strorefront code repository."
  type        = string
}

variable "medusa_storefront_code_repository_url" {
  description = "The url of Medusa Storefront code repository."
  type        = string
}

variable "medusa_storefront_subdomain" {
  description = "The medusa storefront subdomain."
  type        = string
  default     = "store"
}

variable "medusa_backend_url" {
  type = string
}

variable "medusa_main_domain" {
  description = "Main domain of core and storefront."
  type        = string
}

variable "github_access_token" {
  description = "Github access token."
  type        = string
  sensitive   = true
}
