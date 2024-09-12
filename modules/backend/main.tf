data "aws_region" "current" {}

locals {
  prefix = "${var.project}-${var.environment}"

  container_definitions = [
    {
      name   = "${local.prefix}-container"
      image  = var.medusa_image
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
          "awslogs-region"        = data.aws_region.current.name,
          "awslogs-group"         = var.app_log_group
          "awslogs-stream-prefix" = var.app_logs_prefix
        }
      }
      environment = [
        {
          name  = "MEDUSA_CREATE_ADMIN_USER"
          value = tostring(var.medusa_create_admin_user)
        },
        {
          name  = "MEDUSA_RUN_MIGRATION"
          value = tostring(var.medusa_run_migration)
        },
        {
          name  = "MEDUSA_ADMIN_EMAIL"
          value = var.medusa_admin_email
        },
        {
          name  = "MEDUSA_ADMIN_PASSWORD"
          value = var.medusa_admin_password
        },
        {
          name  = "REDIS_URL",
          value = var.elasticache_redis_url
        },
        {
          name  = "DATABASE_URL"
          value = var.postgres_url
        }
      ]
    }
  ]

  tags = {
    Component = "Backend",
    Resource  = "ECS"
  }
}

resource "aws_ecs_cluster" "main" {
  name = "${local.prefix}-ecs-cluster"

  tags = local.tags
}

resource "aws_ecs_task_definition" "medusa_task" {
  family                   = "${local.prefix}-ecs-task-definition"
  execution_role_arn       = aws_iam_role.ecs_task.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.app_cpu
  memory                   = var.app_memory
  container_definitions    = jsonencode(local.container_definitions)

  tags = local.tags
}

resource "aws_ecs_service" "main" {
  name            = "${local.prefix}-ecs-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.medusa_task.arn
  desired_count   = var.app_count
  launch_type     = "FARGATE"
  network_configuration {
    security_groups = [aws_security_group.ecs.id]
    subnets         = var.vpc_private_subnets
  }
  load_balancer {
    container_name   = "${local.prefix}-container"
    target_group_arn = aws_alb_target_group.main.arn
    container_port   = var.app_port
  }

  // TODO: wait_for_steady_state = true

  tags = local.tags
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
  name               = "${local.prefix}-ecs-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json

  tags = local.tags
}

resource "aws_iam_policy" "ecs_task" {
  name   = "${local.prefix}-ecs-task-policy"
  policy = data.aws_iam_policy_document.ecs_task_policy.json

  tags = local.tags
}

resource "aws_iam_role_policy_attachment" "ecs_task" {
  role       = aws_iam_role.ecs_task.name
  policy_arn = aws_iam_policy.ecs_task.arn
}

resource "aws_cloudwatch_log_group" "main" {
  name              = var.app_log_group
  retention_in_days = var.app_logs_retention

  tags = local.tags
}

resource "aws_security_group" "ecs" {
  vpc_id = var.vpc_id

  name        = "${local.prefix}-ecs-sg"
  description = "Allow inbound traffic from ALB on ${var.app_port} port."

  tags = merge(
    { Name = "${local.prefix}-ecs-sg" },
    local.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "ecs" {
  security_group_id            = aws_security_group.ecs.id
  referenced_security_group_id = aws_security_group.alb.id

  from_port   = var.app_port
  ip_protocol = "tcp"
  to_port     = var.app_port

  tags = local.tags
}

resource "aws_vpc_security_group_egress_rule" "ecs" {
  security_group_id = aws_security_group.ecs.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = local.tags
}

resource "aws_alb" "main" {
  subnets         = var.vpc_public_subnets
  security_groups = [aws_security_group.alb.id]
  name            = "${local.prefix}-alb"
  tags            = local.tags
}

resource "aws_alb_target_group" "main" {
  port        = var.app_port
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"
  name        = "${local.prefix}-tg"
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

  tags = local.tags
}

# TODO redirect 80 -> 443
resource "aws_alb_listener" "main" {
  load_balancer_arn = aws_alb.main.arn
  port              = var.listener_port
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-TLS13-1-2-2021-06"
  certificate_arn   = var.certificate_arn

  default_action {
    target_group_arn = aws_alb_target_group.main.arn
    type             = "forward"
  }

  tags = local.tags
}

resource "aws_security_group" "alb" {
  name        = "${local.prefix}-alb-sg"
  description = "Allow inbound traffic from outside on ${var.listener_port} port."

  vpc_id = var.vpc_id

  tags = merge(
    { Name = "${local.prefix}-alb-sg" },
    local.tags
  )
}

resource "aws_vpc_security_group_ingress_rule" "alb" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = aws_alb_listener.main.port
  ip_protocol = "tcp"
  to_port     = aws_alb_listener.main.port

  tags = local.tags
}

# TODO: allow only to ECS
resource "aws_vpc_security_group_egress_rule" "alb" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = local.tags
}
