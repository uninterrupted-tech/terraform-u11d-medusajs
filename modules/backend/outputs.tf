output "medusa_domain" {
  value = aws_route53_record.main.name
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}
