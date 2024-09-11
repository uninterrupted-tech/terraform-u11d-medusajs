data "aws_region" "current" {}

locals {
  prefix = "${var.project}-${var.environment}"
  tags = {
    Component = "Frontend",
    Resource  = "Amplify"
  }
}

resource "aws_amplify_app" "main" {
  name                     = "${local.prefix}-storefront"
  repository               = var.medusa_storefront_code_repository_url
  platform                 = "WEB_COMPUTE"
  enable_branch_auto_build = true
  iam_service_role_arn     = aws_iam_role.amplify.arn

  # TODO: Add posibility to use GH
  # access_token = var.github_access_token

  build_spec = <<-EOT
    version: 1
    frontend:
      phases:
        preBuild:
          commands:
            - yarn install --immutable
        build:
          commands:
            - yarn run build
      artifacts:
        baseDirectory: .next
        files:
          - '**/*'
      cache:
        paths:
          - .next/cache/**/*
          - node_modules/**/*
  EOT


  environment_variables = {
    NEXT_PUBLIC_MEDUSA_BACKEND_URL = var.medusa_backend_url
    NEXT_PUBLIC_BASE_URL           = "http://localhost:80"
    NEXT_PUBLIC_DEFAULT_REGION     = "us"
  }

  tags = local.tags
}

resource "aws_amplify_branch" "main" {
  app_id = aws_amplify_app.main.id

  branch_name       = "main"
  stage             = "PRODUCTION"
  framework         = "Next.js - SSR"
  enable_auto_build = true

  tags = local.tags
}

resource "aws_amplify_domain_association" "main" {
  app_id      = aws_amplify_app.main.id
  domain_name = var.medusa_main_domain

  sub_domain {
    prefix      = var.medusa_storefront_subdomain
    branch_name = aws_amplify_branch.main.branch_name
  }

  # TODO: explain
  # https://eu-west-1.console.aws.amazon.com/amplify/apps/d1hg7dmw6oql7k/domains
  wait_for_verification = false

  depends_on = [aws_amplify_app.main]
}

// Require to run deployment after succeful amplify app creation. Without it you will have to run deployment manually in AWS Console.
resource "null_resource" "trigger_deployment" {
  depends_on = [aws_amplify_branch.main]

  provisioner "local-exec" {
    command = <<EOT
      aws amplify start-job \
        --app-id ${aws_amplify_app.main.id} \
        --branch-name ${aws_amplify_branch.main.branch_name} \
        --region ${data.aws_region.current.name} \
        --job-type RELEASE
    EOT
  }
}

data "aws_iam_policy_document" "amplify_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["amplify.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "amplify_policy" {
  statement {
    actions = [
      "codecommit:GitPull",
    ]
    resources = [var.medusa_storefront_code_repository_arn]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "amplify" {
  name               = "${local.prefix}-amplify-role"
  assume_role_policy = data.aws_iam_policy_document.amplify_assume_role_policy.json

  tags = local.tags
}

resource "aws_iam_policy" "amplify" {
  name = "${local.prefix}-amplify-policy"

  policy = data.aws_iam_policy_document.amplify_policy.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "amplify" {
  role       = aws_iam_role.amplify.name
  policy_arn = aws_iam_policy.amplify.arn
}
