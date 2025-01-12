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