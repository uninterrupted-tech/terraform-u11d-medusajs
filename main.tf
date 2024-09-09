data "aws_partition" "current" {}
data "aws_caller_identity" "current" {}
data "aws_availability_zones" "available" {}

data "aws_iam_session_context" "current" {
  # This data source provides information on the IAM source role of an STS assumed role
  # For non-role ARNs, this data source simply passes the ARN through issuer ARN
  # Ref https://github.com/terraform-aws-modules/terraform-aws-eks/issues/2327#issuecomment-1355581682
  # Ref https://github.com/hashicorp/terraform-provider-aws/issues/28381
  arn = data.aws_caller_identity.current.arn
}

locals {
  global_tags = {
    Project     = var.project
    Environment = var.environment
    Terraform   = true
  }
}
################################################################################
# VPC
################################################################################

locals {
  deploy_vpc = var.create && var.create_vpc

  vpc_tags = merge(
    {
      Component = "VPC",
    },
    local.global_tags
  )
}

resource "aws_vpc" "main" {
  count = local.deploy_vpc ? 1 : 0

  cidr_block = var.vpc_cidr
  tags = merge(
    { Name = "${var.project}-${var.environment}-vpc" },
    local.vpc_tags
  )
}

resource "aws_subnet" "public" {
  count = local.deploy_vpc ? var.az_count : 0

  cidr_block        = cidrsubnet(aws_vpc.main[0].cidr_block, 8, var.az_count + count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main[0].id
  tags = merge(
    { Name = "${var.project}-${var.environment}-public-subnet" },
    local.vpc_tags
  )
}

resource "aws_subnet" "private" {
  count = local.deploy_vpc ? var.az_count : 0

  cidr_block        = cidrsubnet(aws_vpc.main[0].cidr_block, 8, count.index)
  availability_zone = data.aws_availability_zones.available.names[count.index]
  vpc_id            = aws_vpc.main[0].id
  tags = merge(
    { Name = "${var.project}-${var.environment}-private-subnet" },
    local.vpc_tags
  )
}

resource "aws_internet_gateway" "main" {
  count = local.deploy_vpc ? 1 : 0

  vpc_id = aws_vpc.main[0].id
  tags = merge(
    { Name = "${var.project}-${var.environment}-igw" },
    local.vpc_tags
  )
}

resource "aws_route" "main" {
  count = local.deploy_vpc ? 1 : 0

  route_table_id         = aws_vpc.main[0].main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main[0].id
}

################################################################################
# MedusaJS Backend - ECS
################################################################################

locals {
  deploy_backend = var.create && var.create_backend

  db_password = urlencode(jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["password"])

  container_definitions = [
    {
      name   = "${var.project}-${var.environment}-container"
      image  = "${var.ecr_repository}:${var.medusa_image_tag}"
      cpu    = var.app_cpu
      memory = var.app_memory
      portMappings = [
        {
          containerPort = var.app_port
          hostPort      = var.app_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-region"        = var.aws_region,
          "awslogs-group"         = var.app_log_group
          "awslogs-stream-prefix" = var.app_logs_prefix
        }
      }
      environment = [
        {
          name  = "MEDUSA_CREATE_ADMIN_USER"
          value = var.medusa_create_admin_user
        },
        {
          name  = "MEDUSA_RUN_MIGRATION"
          value = var.medusa_run_migration
        },
        {
          name  = "MEDUSA_ADMIN_USERNAME"
          value = var.medusa_admin_username
        },
        {
          name  = "MEDUSA_ADMIN_PASSWORD"
          value = var.medusa_admin_password
        },
        {
          name  = "REDIS_URL",
          value = "redis://${aws_elasticache_cluster.main[0].cache_nodes[0].address}:${aws_elasticache_cluster.main[0].cache_nodes[0].port}"
        },
        {
          name  = "DATABASE_URL"
          value = "postgres://${var.db_username}:${local.db_password}@${aws_db_instance.postgres[0].address}:${aws_db_instance.postgres[0].port}/${aws_db_instance.postgres[0].db_name}?sslmode=no-verify"
        }
      ]
    }
  ]

  ecs_tags = merge(
    {
      Component = "Backend",
      Resource  = "ECS"
    },
    local.global_tags
  )
}

resource "aws_ecs_cluster" "main" {
  count = local.deploy_backend ? 1 : 0

  name = "${var.project}-${var.environment}-ecs-cluster"
  tags = local.ecs_tags
}

resource "aws_ecs_task_definition" "medusa_task" {
  count = local.deploy_backend ? 1 : 0

  family                   = "${var.project}-${var.environment}-ecs-task-definition"
  execution_role_arn       = aws_iam_role.ecs_task[0].arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_cpu
  memory                   = var.app_memory
  container_definitions    = jsonencode(local.container_definitions)
  tags                     = local.ecs_tags
}

resource "aws_ecs_service" "main" {
  count = local.deploy_backend ? 1 : 0

  name            = "${var.project}-${var.environment}-ecs-service"
  cluster         = aws_ecs_cluster.main[0].id
  task_definition = aws_ecs_task_definition.medusa_task[0].arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  network_configuration {
    security_groups  = [aws_security_group.ecs[0].id]
    subnets          = aws_subnet.private[0].*.id
  }
  load_balancer {
    container_name   = "${var.project}-${var.environment}-container"
    target_group_arn = aws_alb_target_group.main[0].arn
    container_port   = var.app_port
  }
  tags = local.ecs_tags
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "ecs_task_policy" {
  statement {
    actions = [
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
    ]
    resources = [var.ecr_arn]
    effect    = "Allow"
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken",
    ]
    resources = ["*"]
    effect    = "Allow"
  }
  statement {
    actions = [
      "logs:PutLogEvents",
      "logs:CreateLogStream"
    ]
    resources = [aws_cloudwatch_log_group.main.arn, "${aws_cloudwatch_log_group.main.arn}:log-stream:*"]
    effect    = "Allow"
  }
}

resource "aws_iam_role" "ecs_task" {
  count = local.deploy_backend ? 1 : 0

  name               = "${var.project}-${var.environment}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
  tags               = local.ecs_tags
}

resource "aws_iam_policy" "ecs_task" {
  count = local.deploy_backend ? 1 : 0

  name   = "${var.project}-${var.environment}-ecs-task-policy"
  policy = data.aws_iam_policy_document.ecs_task_policy.json
  tags   = local.ecs_tags
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  count = local.deploy_backend ? 1 : 0

  role       = aws_iam_role.ecs_task[0].name
  policy_arn = aws_iam_policy.ecs_task[0].arn
}

resource "aws_cloudwatch_log_group" "main" {
  name              = var.app_log_group
  retention_in_days = var.app_logs_retention
  tags              = local.ecs_tags
}

resource "aws_security_group" "ecs" {
  count = local.deploy_backend ? 1 : 0

  vpc_id      = aws_vpc.main[0].id
  name        = "${var.project}-${var.environment}-ecs-sg"
  description = "Allow inbound traffic from ALB on ${var.app_port} port."

  tags = merge(
    { Name = "${var.project}-${var.environment}-ecs-sg" },
    local.ecs_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "ecs" {
  count = local.deploy_db ? 1 : 0

  security_group_id = aws_security_group.ecs[0].id

  referenced_security_group_id = aws_security_group.alb[0].id
  from_port   = var.app_port
  ip_protocol = "tcp"
  to_port     = var.app_port

  tags = local.db_tags
}

resource "aws_vpc_security_group_egress_rule" "ecs" {
  count = local.deploy_db ? 1 : 0

  security_group_id = aws_security_group.ecs[0].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = local.db_tags
}


################################################################################
# MedusaJS Backend - Database
################################################################################

locals {
  deploy_db = var.create && var.create_backend
  db_tags = merge(
    {
      Component = "Backend",
      Resource  = "Database"
    },
    local.global_tags
  )
}

resource "aws_elasticache_cluster" "main" {
  count = local.deploy_db ? 1 : 0

  cluster_id         = "${var.project}-${var.environment}-redis-cluster"
  engine             = "redis"
  node_type          = var.elasticache_node_type
  num_cache_nodes    = var.elasticache_nodes_num
  subnet_group_name  = aws_elasticache_subnet_group.main[0].name
  security_group_ids = [aws_security_group.elasticache[0].id]
  port               = var.elasticache_port
  engine_version     = var.redis_engine_version
  tags               = local.db_tags
}

resource "aws_elasticache_subnet_group" "main" {
  count = local.deploy_db ? 1 : 0

  name        = "${var.project}-${var.environment}-elasticache-db-subnet-group"
  description = "Elasticache subnet group used by ${var.project}-${var.environment}."
  subnet_ids  = aws_subnet.private[0].*.id
  tags        = local.db_tags
}

resource "aws_db_instance" "postgres" {
  count = local.deploy_db ? 1 : 0

  identifier                  = "${var.project}-${var.environment}-postgres"
  db_name                     = "medusa"
  engine                      = "postgres"
  allocated_storage           = var.db_allocated_storage
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  manage_master_user_password = true
  username                    = var.db_username
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.rds[0].id]
  db_subnet_group_name        = aws_db_subnet_group.main[0].name
  skip_final_snapshot         = true
  tags                        = local.db_tags
}

resource "aws_db_subnet_group" "main" {
  count = local.deploy_db ? 1 : 0

  subnet_ids  = aws_subnet.private[0].*.id
  name        = "${var.project}-${var.environment}-db-subnet-group"
  description = "DB subnet group used by${var.project}-${var.environment}."
  tags        = local.db_tags
}

resource "aws_security_group" "rds" {
  count = local.deploy_db ? 1 : 0

  vpc_id      = aws_vpc.main[0].id
  name        = "${var.project}-${var.environment}-rds-sg"
  description = "Allow inbound traffic from ECS on ${var.rds_port} port."
  tags = merge(
    { Name = "${var.project}-${var.environment}-rds-sg" },
    local.db_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "rds" {
  count = local.deploy_db ? 1 : 0

  security_group_id = aws_security_group.rds[0].id

  referenced_security_group_id = aws_security_group.ecs[0].id
  from_port   = aws_db_instance.postgres[0].port
  ip_protocol = "tcp"
  to_port     = aws_db_instance.postgres[0].port

  tags = local.db_tags
}

resource "aws_vpc_security_group_egress_rule" "rds" {
  count = local.deploy_db ? 1 : 0

  security_group_id = aws_security_group.rds[0].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = local.db_tags
}

resource "aws_security_group" "elasticache" {
  count = local.deploy_db ? 1 : 0

  vpc_id      = aws_vpc.main[0].id
  name        = "${var.project}-${var.environment}-elasticache-sg"
  description = "Allow inbound traffic from ECS on ${var.elasticache_port} port."

  tags = merge(
    { Name = "${var.project}-${var.environment}-elasticache-sg" },
    local.db_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "elasticache" {
  count = local.deploy_db ? 1 : 0

  security_group_id = aws_security_group.elasticache[0].id

  referenced_security_group_id = aws_security_group.ecs[0].id
  from_port   = aws_elasticache_cluster.main[0].port
  ip_protocol = "tcp"
  to_port     = aws_elasticache_cluster.main[0].port

  tags = local.db_tags
}

resource "aws_vpc_security_group_egress_rule" "elasticache" {
  count = local.deploy_db ? 1 : 0

  security_group_id = aws_security_group.elasticache[0].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = local.db_tags
}

################################################################################
# MedusaJS Backend - Network
################################################################################

locals {
  deploy_network = var.create && var.create_backend
  network_tags = merge(
    {
      Component = "Backend",
      Resource  = "Network"
    },
    local.global_tags
  )
}

resource "aws_alb" "main" {
  count = local.deploy_network ? 1 : 0

  subnets         = aws_subnet.public[0].*.id
  security_groups = [aws_security_group.alb[0].id]
  name            = "${var.project}-${var.environment}-alb"
  tags            = local.network_tags
}

resource "aws_alb_target_group" "main" {
  count = local.deploy_network ? 1 : 0

  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = aws_vpc.main[0].id
  target_type = "ip"
  name        = "${var.project}-${var.environment}-tg"
  health_check {
    protocol            = "HTTP"
    port                = var.app_port
    interval            = var.health_check_interval
    matcher             = var.health_check_matcher
    timeout             = var.health_check_timeout
    path                = var.health_check_path
    healthy_threshold   = var.health_check_healthy_threshold
    unhealthy_threshold = var.health_check_unhealthy_threshold
  }
  tags = local.network_tags
}

resource "aws_alb_listener" "main" {
  count = local.deploy_network ? 1 : 0

  load_balancer_arn = aws_alb.main[0].arn
  port              = var.listener_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn
  default_action {
    target_group_arn = aws_alb_target_group.main[0].arn
    type             = "forward"
  }
  tags = local.network_tags
}

resource "aws_route53_zone" "primary" {
  count = local.deploy_network ? 1 : 0

  name = var.main_domain
  tags = local.network_tags
}

resource "aws_route53_record" "main" {
  count = local.deploy_network ? 1 : 0

  zone_id = aws_route53_zone.primary[0].id
  name    = "${var.medusa_core_subdomain}.${var.main_domain}"
  type    = "A"

  alias {
    name                   = aws_alb.main[0].dns_name
    zone_id                = aws_alb.main[0].zone_id
    evaluate_target_health = var.route53_evaluate_target_health
  }
}

resource "aws_security_group" "alb" {
  count = local.deploy_network ? 1 : 0

  vpc_id      = aws_vpc.main[0].id
  name        = "${var.project}-${var.environment}-alb-sg"
  description = "Allow inbound traffic from outside on ${var.listener_port} port."

  tags = merge(
    { Name = "${var.project}-${var.environment}-alb-sg" },
    local.network_tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb" {
  count = local.deploy_db ? 1 : 0

  security_group_id = aws_security_group.alb[0].id

  cidr_ipv4 = "0.0.0.0/0"
  from_port   = aws_alb_listener.main[0].port
  ip_protocol = "tcp"
  to_port     = aws_alb_listener.main[0].port

  tags = local.db_tags
}

resource "aws_vpc_security_group_egress_rule" "alb" {
  count = local.deploy_db ? 1 : 0

  security_group_id = aws_security_group.elasticache[0].id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = local.db_tags
}

################################################################################
# MedusaJS Backend - Secrets
################################################################################

locals {
  secrets_tags = merge(
    {
      Component = "Backend",
      Resource  = "Secrets"
    },
    local.global_tags
  )
}

resource "aws_secretsmanager_secret" "medusa" {
  name_prefix = "${var.project}-${var.environment}"
  description = "Medusa admin credentials"
  tags        = local.secrets_tags
}

resource "aws_secretsmanager_secret_version" "medusa" {
  secret_id = aws_secretsmanager_secret.medusa.id
  secret_string = jsonencode({
    username = var.medusa_admin_username
    password = var.medusa_admin_password
  })
}

data "aws_secretsmanager_secret" "rds" {
  count = local.deploy_db ? 1 : 0

  // workaround https://github.com/hashicorp/terraform-provider-aws/issues/31519
  arn  = join("", aws_db_instance.postgres[0].master_user_secret.*.secret_arn)
  tags = local.secrets_tags
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = data.aws_secretsmanager_secret.rds[0].id
}

################################################################################
# MedusaJS Frontend - Amplify
################################################################################

locals {

  deploy_frontend = var.create && var.create_frontend

  amplify_tags = merge(
    {
      Component = "Frontend",
      Resource  = "Amplify"
    },
    local.global_tags
  )
}

resource "aws_amplify_app" "main" {
  count = local.deploy_frontend ? 1 : 0

  name                     = "${var.project}-storefront"
  repository               = var.medusa_storefront_code_repository_url
  platform                 = "WEB_COMPUTE"
  enable_branch_auto_build = true
  iam_service_role_arn     = aws_iam_role.amplify[0].arn

  access_token = try(var.github_access_token, null)

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
    NEXT_PUBLIC_MEDUSA_BACKEND_URL = "https://${aws_route53_record.main[0].name}"
    NEXT_PUBLIC_BASE_URL           = "http://localhost:80"
    NEXT_PUBLIC_DEFAULT_REGION     = "us"
  }
  tags = local.amplify_tags
}

resource "aws_amplify_branch" "main" {
  count = local.deploy_frontend ? 1 : 0

  app_id            = aws_amplify_app.main[0].id
  branch_name       = "main"
  stage             = "PRODUCTION"
  framework         = "Next.js - SSR"
  enable_auto_build = true
  tags              = local.amplify_tags
}

resource "aws_amplify_domain_association" "main" {
  count = local.deploy_frontend ? 1 : 0

  app_id      = aws_amplify_app.main[0].id
  domain_name = var.main_domain

  sub_domain {
    prefix      = var.medusa_storefront_subdomain
    branch_name = aws_amplify_branch.main[0].branch_name
  }

  depends_on = [aws_amplify_app.main]
}

// Require to run deployment after succeful amplify app creation. Without it you will have to run deployment manually in AWS Console.
resource "null_resource" "trigger_deployment" {
  count = local.deploy_frontend ? 1 : 0

  depends_on = [aws_amplify_branch.main]

  provisioner "local-exec" {
    command = <<EOT
      aws amplify start-job \
        --app-id ${aws_amplify_app.main[0].id} \
        --branch-name ${aws_amplify_branch.main[0].branch_name} \
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
  count = local.deploy_frontend ? 1 : 0

  name               = "${var.project}-${var.environment}-amplify-role"
  assume_role_policy = data.aws_iam_policy_document.amplify_assume_role_policy.json
  tags               = local.amplify_tags
}

resource "aws_iam_policy" "amplify" {
  count = local.deploy_frontend ? 1 : 0

  name   = "${var.project}-${var.environment}-amplify-policy"
  policy = data.aws_iam_policy_document.amplify_policy.json
  tags   = local.amplify_tags
}

resource "aws_iam_role_policy_attachment" "amplify" {
  count = local.deploy_frontend ? 1 : 0

  role       = aws_iam_role.amplify[0].name
  policy_arn = aws_iam_policy.amplify[0].arn
}

