variable "medusa_main_domain" {
  description = "Main domain of core and storefront."
  type        = string
}

variable "medusa_core_subdomain" {
  description = "The medusa core subdomain."
  type        = string
  default     = "api"
}

variable "medusa_core_alb" {
  description = "Core ALB"
  type = object({
    dns_name = string
    zone_id  = string
  })
}

variable "route53_evaluate_target_health" {
  description = "Specify if you want Route 53 to determine whether to respond to DNS queries using this resource record set by checking the health of the resource record set."
  type        = string
  default     = true
}
