output "medusa_alb" {
  value = aws_alb.main
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs.id
}
