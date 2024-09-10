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

module "complete" {
  source = "../../"

  project     = local.project
  environment = local.environment

  # TODO: Generate cert if you don't have one
  certificate_arn = "arn:aws:acm:eu-west-1:090489944851:certificate/dbb0a78c-edd2-4489-b8d0-cf66395b1f02"
  # TODO: Only backend move to backend
  ecr_arn = "arn:aws:ecr:eu-west-1:090489944851:repository/medusa-core"

  github_access_token = "tbd"

  medusa_admin_username = "admin@uninterrupted.tech"
  medusa_admin_password = "password"
  medusa_main_domain    = "uninterrupted.tech"
  medusa_image          = "090489944851.dkr.ecr.eu-west-1.amazonaws.com/medusa-core:latest"

  medusa_storefront_code_repository_arn = "arn:aws:codecommit:eu-west-1:090489944851:medusa-storefront"
  medusa_storefront_code_repository_url = "https://git-codecommit.eu-west-1.amazonaws.com/v1/repos/medusa-storefront"
}
