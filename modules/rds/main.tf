locals {
  prefix = "${var.project}-${var.environment}"
  tags   = { Component = "RDS" }
}

data "aws_secretsmanager_secret" "rds" {
  // workaround https://github.com/hashicorp/terraform-provider-aws/issues/31519
  arn = join("", aws_db_instance.postgres.master_user_secret.*.secret_arn)
}

data "aws_secretsmanager_secret_version" "rds" {
  secret_id = data.aws_secretsmanager_secret.rds.id
}

resource "aws_security_group" "rds" {
  name        = "${local.prefix}-rds-sg"
  description = "Allow communitcation from ECS"

  vpc_id = var.vpc_id

  # TODO: Check if name tag is needed
  tags = merge({ Name = "${local.prefix}-rds-sg" }, local.tags)
}

resource "aws_vpc_security_group_ingress_rule" "rds" {
  security_group_id            = aws_security_group.rds.id
  referenced_security_group_id = var.ecs_security_group_id

  from_port   = aws_db_instance.postgres.port
  ip_protocol = "tcp"
  to_port     = aws_db_instance.postgres.port

  tags = local.tags
}

resource "aws_vpc_security_group_egress_rule" "rds" {
  security_group_id = aws_security_group.rds.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = local.tags
}

resource "aws_db_subnet_group" "main" {
  name        = "${local.prefix}-db-subnet-group"
  description = "DB subnet group used by${local.prefix}."

  subnet_ids = var.vpc_private_subnets

  tags = local.tags
}

resource "aws_db_instance" "postgres" {
  identifier                  = "${local.prefix}-postgres"
  db_name                     = "medusa"
  engine                      = "postgres"
  allocated_storage           = var.db_allocated_storage
  engine_version              = var.db_engine_version
  instance_class              = var.db_instance_class
  manage_master_user_password = true
  username                    = var.db_username
  publicly_accessible         = false
  vpc_security_group_ids      = [aws_security_group.rds.id]
  db_subnet_group_name        = aws_db_subnet_group.main.name
  skip_final_snapshot         = true

  tags = local.tags
}
