locals {
  tags = {
    Component = "Certificates",
  }
}

resource "aws_acm_certificate" "main" {
  # TODO: conditionals
  domain_name = var.medusa_main_domain
  subject_alternative_names = [
    "${var.medusa_subdomain}.${var.medusa_main_domain}",
  ]
  validation_method = "DNS"
}

resource "aws_route53_record" "main" {
  for_each = {
    for dvo in aws_acm_certificate.main.domain_validation_options : dvo.domain_name => {
      name   = dvo.resource_record_name
      record = dvo.resource_record_value
      type   = dvo.resource_record_type
    }
  }

  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = var.route53_zone_id
}
