data "aws_route53_zone" "my_route53_zone" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "my_record" {
  zone_id = data.aws_route53_zone.my_route53_zone.zone_id
  name    = "blog.${data.aws_route53_zone.my_route53_zone.name}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.cdn.domain_name
    zone_id                = aws_cloudfront_distribution.cdn.hosted_zone_id
    evaluate_target_health = false
  }
}