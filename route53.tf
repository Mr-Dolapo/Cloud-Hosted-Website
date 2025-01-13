resource "aws_route53domains_registered_domain" "dolapoadeeyocv" {
  domain_name = "dolapoadeeyocv.com"

  dynamic "name_server" {
    for_each = data.aws_route53_zone.default_zone.name_servers
    content {
      name = name_server.value
    }
  }

  tags = {
    Name = "Default domain"
  }
}

resource "aws_route53_zone" "default_zone" {
  name = "dolapoadeeyocv.com"
}

# Fetch validation details from the certificate data
resource "aws_route53_record" "certificate_validation" {
  zone_id = data.aws_route53_zone.default_zone.zone_id
  name    = var.cname_name
  type    = "CNAME"
  ttl     = 60
  records = [var.cname_value]
}

resource "aws_route53_record" "certificate_validation_www" {
  zone_id = data.aws_route53_zone.default_zone.zone_id
  name    = var.cname_name_www
  type    = "CNAME"
  ttl     = 60
  records = [var.cname_value_www]
}

resource "aws_route53_record" "default_cloudfront_record" {
  zone_id = aws_route53_zone.default_zone.id
  name    = "dolapoadeeyocv.com"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.default_website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.default_website_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "default_cloudfront_record_www" {
  zone_id = aws_route53_zone.default_zone.id
  name    = "www.dolapoadeeyocv.com"
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.default_website_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.default_website_distribution.hosted_zone_id
    evaluate_target_health = true
  }
}