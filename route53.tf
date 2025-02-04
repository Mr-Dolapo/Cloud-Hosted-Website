###################################################################################################
# Route 53 Domain Registration
#
# This resource registers the domain "dolapoadeeyocv.com" via Route 53.
# It uses a dynamic block to add each name server from the Route 53 hosted zone data.
###################################################################################################
resource "aws_route53domains_registered_domain" "dolapoadeeyocv" {
  domain_name = "dolapoadeeyocv.com"  # The domain to register

  # Use a dynamic block to iterate over the name servers provided by the Route 53 zone data.
  dynamic "name_server" {
    for_each = data.aws_route53_zone.default_zone.name_servers  # Iterates over each name server
    content {
      name = name_server.value  # Sets the name server name from the data source
    }
  }

  tags = {
    Name        = "${var.environment_prod}-domain"  # Tag the domain with environment info for organization
    Environment = "${var.environment_prod}"
  }
}

###################################################################################################
# Route 53 Hosted Zone
#
# This resource creates (or manages) a hosted zone for the domain "dolapoadeeyocv.com".
# The hosted zone is used to manage DNS records for the domain.
###################################################################################################
resource "aws_route53_zone" "default_zone" {
  name = "dolapoadeeyocv.com"  # Domain name for the hosted zone

  tags = {
    Name        = "${var.environment_prod}-route53-zone"  # Tag for identification and organization
    Environment = "${var.environment_prod}"
  }
}

###################################################################################################
# DNS Record for Certificate Validation (CNAME)
#
# This resource creates a CNAME record for validating the ACM certificate.
# It fetches the validation details (CNAME) from variables passed in.
###################################################################################################
resource "aws_route53_record" "certificate_validation" {
  zone_id = data.aws_route53_zone.default_zone.zone_id  # Use the hosted zone ID from the data source
  name    = var.cname_name                               # The record name for certificate validation
  type    = "CNAME"                                      # Record type is CNAME for validation
  ttl     = 60                                           # Time-to-live for DNS caching
  records = [var.cname_value]                            # The validation CNAME value from variables
}

###################################################################################################
# DNS Record for Certificate Validation (CNAME) for www
#
# This record validates the ACM certificate for the www subdomain.
###################################################################################################
resource "aws_route53_record" "certificate_validation_www" {
  zone_id = data.aws_route53_zone.default_zone.zone_id  # Hosted zone ID from the data source
  name    = var.cname_name_www                           # Record name for the www subdomain
  type    = "CNAME"
  ttl     = 60
  records = [var.cname_value_www]                        # Validation value for the www subdomain
}

###################################################################################################
# DNS Record for Certificate Validation (CNAME) for app
#
# This record validates the ACM certificate for the app subdomain.
###################################################################################################
resource "aws_route53_record" "certificate_validation_app" {
  zone_id = data.aws_route53_zone.default_zone.zone_id  # Hosted zone ID from the data source
  name    = var.cname_name_app                           # Record name for the app subdomain
  type    = "CNAME"
  ttl     = 60
  records = [var.cname_value_app]                        # Validation value for the app subdomain
}

###################################################################################################
# Alias Record for CloudFront Distribution (Root Domain)
#
# This resource creates an alias A record for "dolapoadeeyocv.com" that points to the CloudFront
# distribution serving your S3-hosted website.
###################################################################################################
resource "aws_route53_record" "default_cloudfront_record" {
  zone_id = aws_route53_zone.default_zone.id             # The ID of your hosted zone
  name    = "dolapoadeeyocv.com"                           # The root domain name
  type    = "A"                                          # Alias A record for IPv4
  alias {
    name                   = aws_cloudfront_distribution.default_website_distribution.domain_name  # CloudFront distribution domain name
    zone_id                = aws_cloudfront_distribution.default_website_distribution.hosted_zone_id # CloudFront's hosted zone ID
    evaluate_target_health = true  # Evaluate the health of the target before routing traffic
  }
}

###################################################################################################
# Alias Record for CloudFront Distribution (www Subdomain)
#
# This resource creates an alias A record for "www.dolapoadeeyocv.com" pointing to the same CloudFront
# distribution as the root domain.
###################################################################################################
resource "aws_route53_record" "default_cloudfront_record_www" {
  zone_id = aws_route53_zone.default_zone.id             # Hosted zone ID
  name    = "www.dolapoadeeyocv.com"                       # www subdomain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.default_website_distribution.domain_name  # CloudFront distribution domain name
    zone_id                = aws_cloudfront_distribution.default_website_distribution.hosted_zone_id # CloudFront's hosted zone ID
    evaluate_target_health = true  # Enable health checks
  }
}

###################################################################################################
# Alias Record for CloudFront Distribution for Application (app Subdomain)
#
# This resource creates an alias A record for "app.dolapoadeeyocv.com" that points to the CloudFront
# distribution serving your ALB-based application.
###################################################################################################
resource "aws_route53_record" "app_cloudfront_record" {
  zone_id = aws_route53_zone.default_zone.id             # Hosted zone ID
  name    = "app.dolapoadeeyocv.com"                       # app subdomain
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.app_distribution.domain_name  # Domain name of the ALB-based CloudFront distribution
    zone_id                = aws_cloudfront_distribution.app_distribution.hosted_zone_id # CloudFront's hosted zone ID for the ALB distribution
    evaluate_target_health = true  # Enable health evaluation for routing decisions
  }
}
