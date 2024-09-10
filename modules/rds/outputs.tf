locals {
  password = urlencode(jsondecode(data.aws_secretsmanager_secret_version.rds.secret_string)["password"])
}

output "postgres_url" {
  value = "postgres://${var.db_username}:${local.password}@${aws_db_instance.postgres.address}:${aws_db_instance.postgres.port}/${aws_db_instance.postgres.db_name}?sslmode=no-verify"
}
