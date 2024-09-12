terraform {
  required_version = "~> 1.9.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.64.0"
    }
  }
}

provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Project     = var.project
      Environment = var.environment
      Terraform   = true
    }
  }
}

module "complete" {
  source = "../../"

  project     = var.project
  environment = var.environment

  # TODO: Generate cert if you don't have one
  # certificate_arn = "arn:aws:acm:eu-west-1:090489944851:certificate/dbb0a78c-edd2-4489-b8d0-cf66395b1f02"
  # TODO: Only backend move to backend
  ecr_arn = "arn:aws:ecr:eu-west-1:090489944851:repository/medusa-core"

  github_access_token = "tbd"

  medusa_create_admin_user = false
  medusa_admin_email       = "admin@uninterrupted.tech"
  medusa_admin_password    = "password"
  medusa_main_domain       = "medusa-terraform.uninterrupted.tech"
  medusa_image             = "090489944851.dkr.ecr.eu-west-1.amazonaws.com/medusa-core:0e4690cb"

  medusa_storefront_code_repository_arn = "arn:aws:codecommit:eu-west-1:090489944851:medusa-storefront"
  medusa_storefront_code_repository_url = "https://git-codecommit.eu-west-1.amazonaws.com/v1/repos/medusa-storefront"
}
