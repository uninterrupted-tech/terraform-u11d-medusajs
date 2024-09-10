terraform {
  required_version = "~> 1.10.0"
}

locals {
  project     = "medusa"
  environment = "prod"
}

provider "aws" {
  region = "eu-west-1"
  default_tags {
    tags = {
      Project     = local.project
      Environment = local.environment
      Terraform   = true
    }
  }
}

module "minimal" {
  source = "../../"

  project     = local.project
  environment = local.environment

  ecr_storefront_create = true

  backend_container_image = "ghcr.io/uninterrupted-tech/medusajs-backend:1.20.10-788e83e"
  backend_container_registry_credentials = { // Required until we make images public
    username = "xxx"
    password = "xxx"
  }
  backend_seed_create = true
  backend_seed_run    = true
  # backend_admin_credentials = { // Use seed or create admin user separately
  #   email = "admin@medusa.starter"
  # }
  backend_extra_environment_variables = { // TBD: Where to put these? Image or module?
    "NODE_ENV" : "development"
  }

  storefront_create          = false // Enable once image is built and pushed
  storefront_container_image = "xxx" // Full name of the image, including registry and tag
}

output "ecr_backend_url" {
  value = module.minimal.ecr_backend_url
}

output "ecr_storefront_url" {
  value = module.minimal.ecr_storefront_url
}

output "backend_url" {
  value = module.minimal.backend_url
}

output "storefront_url" {
  value = module.minimal.storefront_url
}
