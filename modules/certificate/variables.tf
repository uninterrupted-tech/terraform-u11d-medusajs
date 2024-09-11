variable "medusa_main_domain" {
  description = "Main domain of core and storefront."
  type        = string
}

variable "medusa_subdomain" {
  description = "The medusa component subdomain."
  type        = string
}

variable "route53_zone_id" {
  description = "Zone ID"
  type        = string
}
