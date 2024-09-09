output "medusa_domain" {
  value = aws_route53_record.main[0].name
}
