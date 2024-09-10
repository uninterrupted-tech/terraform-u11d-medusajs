data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}

resource "aws_secretsmanager_secret" "medusa" {
  name_prefix = "${var.project}-${var.environment}"
  description = "Medusa admin credentials"

  tags = {
    Component = "Backend",
    Resource  = "Secrets"
  }
}

resource "aws_secretsmanager_secret_version" "medusa" {
  secret_id = aws_secretsmanager_secret.medusa.id
  secret_string = jsonencode({
    username = var.medusa_admin_username
    password = var.medusa_admin_password
  })
}

module "vpc" {
  source = "./modules/vpc"

  count = var.create_vpc ? 1 : 0

  project     = var.project
  environment = var.environment

  az_count = var.az_count
}

module "elasticache" {
  source = "./modules/elasticache"

  count = var.create_elasticache ? 1 : 0

  project     = var.project
  environment = var.environment

  # TODO: Add possibility to add vpc variables through variables
  vpc_id              = module.vpc[0].vpc_id
  vpc_private_subnets = module.vpc[0].private_subnets

  ecs_security_group_id = module.backend[0].ecs_security_group_id
}

module "rds" {
  source = "./modules/rds"

  count = var.create_rds ? 1 : 0

  project     = var.project
  environment = var.environment

  db_username = var.db_username

  vpc_id              = module.vpc[0].vpc_id
  vpc_private_subnets = module.vpc[0].private_subnets

  ecs_security_group_id = module.backend[0].ecs_security_group_id
}

module "backend" {
  source = "./modules/backend"

  count = var.create_backend ? 1 : 0

  project     = var.project
  environment = var.environment

  ecr_arn         = var.ecr_arn
  certificate_arn = var.certificate_arn

  medusa_admin_username = var.medusa_admin_username
  medusa_admin_password = var.medusa_admin_password
  medusa_image          = var.medusa_image
  medusa_run_migration  = var.medusa_run_migration
  medusa_core_subdomain = var.medusa_core_subdomain
  medusa_main_domain    = var.medusa_main_domain

  vpc_id              = module.vpc[0].vpc_id
  vpc_public_subnets  = module.vpc[0].public_subnets
  vpc_private_subnets = module.vpc[0].private_subnets

  elasticache_redis_url         = module.elasticache[0].redis_url
  elasticache_security_group_id = module.elasticache[0].security_group_id

  postgres_url = module.rds[0].postgres_url
}

module "storefront" {
  source = "./modules/storefront"

  count = var.create_storefront ? 1 : 0

  project     = var.project
  environment = var.environment

  medusa_main_domain                    = var.medusa_main_domain
  medusa_storefront_subdomain           = var.medusa_storefront_subdomain
  medusa_storefront_code_repository_arn = var.medusa_storefront_code_repository_arn
  medusa_storefront_code_repository_url = var.medusa_storefront_code_repository_url
  medusa_backend_url                    = module.backend[0].medusa_domain

  github_access_token = var.github_access_token
}
