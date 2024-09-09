# terraform-u11d-medusajs
Terraform module to create MedusaJS resources

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.9.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | ~>5.64.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 5.64.0 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.2 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_alb.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb) | resource |
| [aws_alb_listener.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_listener) | resource |
| [aws_alb_target_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/alb_target_group) | resource |
| [aws_amplify_app.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_app) | resource |
| [aws_amplify_branch.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_branch) | resource |
| [aws_amplify_domain_association.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/amplify_domain_association) | resource |
| [aws_cloudwatch_log_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/cloudwatch_log_group) | resource |
| [aws_db_instance.postgres](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |
| [aws_ecs_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_cluster) | resource |
| [aws_ecs_service.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_service) | resource |
| [aws_ecs_task_definition.medusa_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecs_task_definition) | resource |
| [aws_elasticache_cluster.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_cluster) | resource |
| [aws_elasticache_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/elasticache_subnet_group) | resource |
| [aws_iam_policy.amplify](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_policy.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_policy) | resource |
| [aws_iam_role.amplify](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role) | resource |
| [aws_iam_role_policy_attachment.amplify](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_iam_role_policy_attachment.ecs_task](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/iam_role_policy_attachment) | resource |
| [aws_internet_gateway.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/internet_gateway) | resource |
| [aws_route.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route) | resource |
| [aws_route53_record.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_record) | resource |
| [aws_route53_zone.primary](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/route53_zone) | resource |
| [aws_secretsmanager_secret.medusa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret) | resource |
| [aws_secretsmanager_secret_version.medusa](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/secretsmanager_secret_version) | resource |
| [aws_security_group.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_security_group.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/security_group) | resource |
| [aws_subnet.private](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_subnet.public](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/subnet) | resource |
| [aws_vpc.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc) | resource |
| [aws_vpc_security_group_egress_rule.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_egress_rule.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_egress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.alb](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.ecs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.elasticache](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [aws_vpc_security_group_ingress_rule.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/vpc_security_group_ingress_rule) | resource |
| [null_resource.trigger_deployment](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [aws_availability_zones.available](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/availability_zones) | data source |
| [aws_caller_identity.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/caller_identity) | data source |
| [aws_iam_policy_document.amplify_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.amplify_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_assume_role_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_policy_document.ecs_task_policy](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_policy_document) | data source |
| [aws_iam_session_context.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/iam_session_context) | data source |
| [aws_partition.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/partition) | data source |
| [aws_secretsmanager_secret.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret) | data source |
| [aws_secretsmanager_secret_version.rds](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/secretsmanager_secret_version) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_app_count"></a> [app\_count](#input\_app\_count) | Number of docker containers to run. | `number` | `1` | no |
| <a name="input_app_cpu"></a> [app\_cpu](#input\_app\_cpu) | Fargate instance CPU units to provision (1 vCPU = 1024 CPU units). | `number` | `2048` | no |
| <a name="input_app_log_group"></a> [app\_log\_group](#input\_app\_log\_group) | Name of the application log group in CloudWatch. | `string` | `"/medusa"` | no |
| <a name="input_app_logs_prefix"></a> [app\_logs\_prefix](#input\_app\_logs\_prefix) | Application logs prefix. | `string` | `"container"` | no |
| <a name="input_app_logs_retention"></a> [app\_logs\_retention](#input\_app\_logs\_retention) | Log retention in days. | `number` | `30` | no |
| <a name="input_app_memory"></a> [app\_memory](#input\_app\_memory) | Fargate instance memory to provision (in MiB). | `number` | `4096` | no |
| <a name="input_app_port"></a> [app\_port](#input\_app\_port) | Port exposed by the docker image to redirect traffic to. | `number` | `9000` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | Your AWS region. | `any` | n/a | yes |
| <a name="input_az_count"></a> [az\_count](#input\_az\_count) | Number of AZs to cover in a given region. | `number` | `2` | no |
| <a name="input_certificate_arn"></a> [certificate\_arn](#input\_certificate\_arn) | ARN of the default SSL server certificate. | `string` | n/a | yes |
| <a name="input_create"></a> [create](#input\_create) | Enable resource creation | `bool` | `true` | no |
| <a name="input_create_backend"></a> [create\_backend](#input\_create\_backend) | Enable backend resources creation | `bool` | `true` | no |
| <a name="input_create_frontend"></a> [create\_frontend](#input\_create\_frontend) | Enable frontend resources creation | `bool` | `true` | no |
| <a name="input_create_vpc"></a> [create\_vpc](#input\_create\_vpc) | Enable vpc creation | `bool` | `true` | no |
| <a name="input_db_allocated_storage"></a> [db\_allocated\_storage](#input\_db\_allocated\_storage) | The allocated storage in gibibytes. | `number` | `5` | no |
| <a name="input_db_engine_version"></a> [db\_engine\_version](#input\_db\_engine\_version) | The postgres engine version to use. You can provide a prefix of the version such as 8.0 (for 8.0.36). | `string` | `"15.6"` | no |
| <a name="input_db_instance_class"></a> [db\_instance\_class](#input\_db\_instance\_class) | The instance type of the RDS instance. | `string` | `"db.t3.micro"` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | The username used to authenticate with the PostgreSQL database. | `string` | n/a | yes |
| <a name="input_ecr_arn"></a> [ecr\_arn](#input\_ecr\_arn) | ARN of Elastic Container Registry. | `string` | n/a | yes |
| <a name="input_ecr_repository"></a> [ecr\_repository](#input\_ecr\_repository) | ECR repository for the Medusa docker image. | `string` | n/a | yes |
| <a name="input_elasticache_node_type"></a> [elasticache\_node\_type](#input\_elasticache\_node\_type) | The Elasticache instance class used. | `string` | `"cache.t3.micro"` | no |
| <a name="input_elasticache_nodes_num"></a> [elasticache\_nodes\_num](#input\_elasticache\_nodes\_num) | The initial number of cache nodes that the cache cluster will have. | `number` | `1` | no |
| <a name="input_elasticache_port"></a> [elasticache\_port](#input\_elasticache\_port) | Port exposed by the redis to redirect traffic to. | `number` | `6379` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | The name of the environment for which infrastructure is being provisioned. | `string` | `"prod"` | no |
| <a name="input_health_check_healthy_threshold"></a> [health\_check\_healthy\_threshold](#input\_health\_check\_healthy\_threshold) | Number of consecutive health check successes required before considering a target healthy. | `number` | `3` | no |
| <a name="input_health_check_interval"></a> [health\_check\_interval](#input\_health\_check\_interval) | Approximate amount of time, in seconds, between health checks of an individual target. | `number` | `30` | no |
| <a name="input_health_check_matcher"></a> [health\_check\_matcher](#input\_health\_check\_matcher) | The HTTP code to use when checking for a successful response from a target. | `number` | `200` | no |
| <a name="input_health_check_path"></a> [health\_check\_path](#input\_health\_check\_path) | The path to monitor the health status of the service. | `string` | `"/health"` | no |
| <a name="input_health_check_timeout"></a> [health\_check\_timeout](#input\_health\_check\_timeout) | Amount of time, in seconds, during which no response from a target means a failed health check. | `number` | `3` | no |
| <a name="input_health_check_unhealthy_threshold"></a> [health\_check\_unhealthy\_threshold](#input\_health\_check\_unhealthy\_threshold) | Number of consecutive health check failures required before considering a target unhealthy. | `number` | `3` | no |
| <a name="input_listener_port"></a> [listener\_port](#input\_listener\_port) | The port on which the ALB listens for incoming traffic. | `number` | `443` | no |
| <a name="input_main_domain"></a> [main\_domain](#input\_main\_domain) | Main domain of core and storefront. | `string` | n/a | yes |
| <a name="input_medusa_admin_password"></a> [medusa\_admin\_password](#input\_medusa\_admin\_password) | The medusa admin password. | `string` | n/a | yes |
| <a name="input_medusa_admin_username"></a> [medusa\_admin\_username](#input\_medusa\_admin\_username) | The medusa admin username. | `string` | n/a | yes |
| <a name="input_medusa_core_subdomain"></a> [medusa\_core\_subdomain](#input\_medusa\_core\_subdomain) | The medusa core subdomain. | `string` | n/a | yes |
| <a name="input_medusa_create_admin_user"></a> [medusa\_create\_admin\_user](#input\_medusa\_create\_admin\_user) | Specify if database should be initilize with admin. | `bool` | `true` | no |
| <a name="input_medusa_image_tag"></a> [medusa\_image\_tag](#input\_medusa\_image\_tag) | Image tag of the docker image to run in the ECS cluster. | `string` | n/a | yes |
| <a name="input_medusa_run_migration"></a> [medusa\_run\_migration](#input\_medusa\_run\_migration) | Specify medusa migrations should be run on start. | `bool` | `true` | no |
| <a name="input_medusa_storefront_code_repository_arn"></a> [medusa\_storefront\_code\_repository\_arn](#input\_medusa\_storefront\_code\_repository\_arn) | ARN of the Medusa Strorefront code repository. | `string` | n/a | yes |
| <a name="input_medusa_storefront_code_repository_url"></a> [medusa\_storefront\_code\_repository\_url](#input\_medusa\_storefront\_code\_repository\_url) | The url of Medusa Storefront code repository. | `string` | n/a | yes |
| <a name="input_medusa_storefront_subdomain"></a> [medusa\_storefront\_subdomain](#input\_medusa\_storefront\_subdomain) | The medusa storefront subdomain. | `string` | n/a | yes |
| <a name="input_project"></a> [project](#input\_project) | The name of the project for which infrastructure is being provisioned. | `string` | `"medusa"` | no |
| <a name="input_rds_port"></a> [rds\_port](#input\_rds\_port) | Port exposed by the RDS to redirect traffic to. | `number` | `5432` | no |
| <a name="input_redis_engine_version"></a> [redis\_engine\_version](#input\_redis\_engine\_version) | The version of the redis that will be used to create the Elasticache cluster. You can provide a prefix of the version such as 7.1 (for 7.1.4). | `string` | `"7.1"` | no |
| <a name="input_route53_evaluate_target_health"></a> [route53\_evaluate\_target\_health](#input\_route53\_evaluate\_target\_health) | Specify if you want Route 53 to determine whether to respond to DNS queries using this resource record set by checking the health of the resource record set. | `string` | `true` | no |
| <a name="input_route53_zone_id"></a> [route53\_zone\_id](#input\_route53\_zone\_id) | The ID of the hosted zone to contain the record. | `string` | n/a | yes |
| <a name="input_vpc_cidr"></a> [vpc\_cidr](#input\_vpc\_cidr) | CIDR block used in VPC | `string` | `"172.16.0.0/16"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_medusa_domain"></a> [medusa\_domain](#output\_medusa\_domain) | n/a |
<!-- END_TF_DOCS -->