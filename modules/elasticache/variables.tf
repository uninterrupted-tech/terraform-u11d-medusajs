variable "project" {
  description = "The name of the project for which infrastructure is being provisioned."
  type        = string
}

variable "environment" {
  description = "The name of the environment for which infrastructure is being provisioned."
  type        = string
}

variable "elasticache_node_type" {
  description = "The Elasticache instance class used."
  type        = string
  default     = "cache.t3.micro"
}

variable "elasticache_nodes_num" {
  description = "The initial number of cache nodes that the cache cluster will have."
  type        = number
  default     = 1
}

variable "elasticache_port" {
  description = "Port exposed by the redis to redirect traffic to."
  type        = number
  default     = 6379
}

variable "elasticache_redis_engine_version" {
  description = "The version of the redis that will be used to create the Elasticache cluster. You can provide a prefix of the version such as 7.1 (for 7.1.4)."
  type        = string
  default     = "7.1"
}

variable "vpc_id" {
  type = string
}

variable "vpc_private_subnets" {
  type = list(string)
}

variable "ecs_security_group_id" {
  type = string
}
