locals {
  prefix = "${var.project}-${var.environment}"
  tags   = { Component = "Elasticache" }
}

resource "aws_security_group" "elasticache" {
  name        = "${local.prefix}-elasticache-sg"
  description = "Allow communication with ECS"

  vpc_id = var.vpc_id

  # TODO: Check if the name tag is needed
  tags = merge({ Name = "${local.prefix}-elasticache-sg" }, local.tags)
}

resource "aws_elasticache_subnet_group" "main" {
  name        = "${local.prefix}-elasticache-db-subnet-group"
  description = "Elasticache subnet group used by ${local.prefix}."

  subnet_ids = var.vpc_private_subnets

  tags = local.tags
}

resource "aws_vpc_security_group_ingress_rule" "elasticache" {
  security_group_id            = aws_security_group.elasticache.id
  referenced_security_group_id = var.ecs_security_group_id

  from_port   = aws_elasticache_cluster.main.port
  ip_protocol = "tcp"
  to_port     = aws_elasticache_cluster.main.port

  tags = local.tags
}

resource "aws_vpc_security_group_egress_rule" "elasticache" {
  security_group_id = aws_security_group.elasticache.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"

  tags = local.tags
}

resource "aws_elasticache_cluster" "main" {
  cluster_id = "${local.prefix}-redis-cluster"

  engine             = "redis"
  node_type          = var.elasticache_node_type
  num_cache_nodes    = var.elasticache_nodes_num
  subnet_group_name  = aws_elasticache_subnet_group.main.name
  security_group_ids = [aws_security_group.elasticache.id]
  port               = var.elasticache_port
  engine_version     = var.elasticache_redis_engine_version

  tags = local.tags
}
