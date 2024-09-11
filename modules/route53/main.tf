locals {
  tags = {
    Component = "Route53",
  }
}

resource "aws_route53_zone" "primary" {
  name = var.medusa_main_domain

  tags = local.tags
}

resource "aws_route53_record" "core" {
  name = "${var.medusa_core_subdomain}.${var.medusa_main_domain}"
  type = "A"

  zone_id = aws_route53_zone.primary.id

  alias {
    name                   = var.medusa_core_alb.dns_name
    zone_id                = var.medusa_core_alb.zone_id
    evaluate_target_health = var.route53_evaluate_target_health
  }
}
