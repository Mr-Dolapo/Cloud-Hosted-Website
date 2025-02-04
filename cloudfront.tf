###################################################################################################
# CloudFront Origin Access Control (OAC)
#
# This resource creates an Origin Access Control for CloudFront that is used when
# accessing an S3 origin. It tells CloudFront to always sign requests (using AWS SigV4)
# when accessing the specified S3 bucket.
###################################################################################################
resource "aws_cloudfront_origin_access_control" "default_cloudfront_oac" {
  name                              = "default_cloudfront_oai" # A friendly name for the OAC.
  description                       = "default_cloudfront_oai" # A description for clarity.
  origin_access_control_origin_type = "s3"                     # Specifies that this OAC is for an S3 origin.
  signing_behavior                  = "always"                 # Always sign requests to the origin.
  signing_protocol                  = "sigv4"                  # Use AWS Signature Version 4 for signing.
}

###################################################################################################
# CloudFront Distribution for S3 Website
#
# This distribution serves static website content from an S3 bucket.
# It uses a custom domain (aliases) and an ACM certificate for HTTPS.
###################################################################################################
resource "aws_cloudfront_distribution" "default_website_distribution" {
  default_root_object = "index.html"                                     # The default file to serve if none is specified.
  enabled             = true                                             # Enable the distribution.
  price_class         = "PriceClass_100"                                 # Restrict distribution to specific edge locations for cost savings.
  aliases             = ["dolapoadeeyocv.com", "www.dolapoadeeyocv.com"] # Custom domain names (CNAMEs).

  # Configure the viewer certificate using an ACM certificate for HTTPS.
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.default_certificate.arn # ACM certificate ARN.
    ssl_support_method       = "sni-only"                                  # Use SNI for HTTPS.
    minimum_protocol_version = "TLSv1.2_2021"                              # Enforce TLS 1.2 (or higher).
  }

  # Define the S3 origin for the distribution.
  origin {
    domain_name              = aws_s3_bucket.default_website_bucket.bucket_regional_domain_name # S3 bucket regional domain name.
    origin_id                = aws_s3_bucket.default_website_bucket.bucket                      # Unique identifier for the origin.
    origin_access_control_id = aws_cloudfront_origin_access_control.default_cloudfront_oac.id   # Associate the OAC for secure access.
  }

  # Configure the default cache behavior for requests.
  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]                             # Allow only GET and HEAD requests.
    cached_methods         = ["GET", "HEAD"]                             # Cache responses for GET and HEAD.
    target_origin_id       = aws_s3_bucket.default_website_bucket.bucket # Specifies which origin this cache behavior uses.
    viewer_protocol_policy = "redirect-to-https"                         # Redirect HTTP requests to HTTPS.

    # Define what values are forwarded to the origin.
    forwarded_values {
      query_string = false # Do not forward query strings.
      cookies {
        forward = "none" # Do not forward cookies.
      }
    }
    min_ttl     = 0    # Minimum time-to-live for cached objects.
    max_ttl     = 3600 # Maximum TTL (1 hour).
    default_ttl = 3600 # Default TTL (1 hour).
  }

  # No geographic restrictions.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Tags for resource organization and cost allocation.
  tags = {
    Name        = "${var.environment_prod}-distribution-s3" # Name tag using the production environment variable.
    Environment = "${var.environment_prod}"                 # Environment tag.
  }
}

###################################################################################################
# CloudFront Distribution for Application Load Balancer (ALB)
#
# This distribution routes traffic to an ALB-based application. It is configured with
# custom origin settings for the ALB and uses a custom domain alias.
###################################################################################################
resource "aws_cloudfront_distribution" "app_distribution" {
  aliases = ["app.dolapoadeeyocv.com"] # Custom domain for the application.

  # Define the ALB as the origin.
  origin {
    domain_name = aws_lb.app_lb.dns_name # DNS name of the ALB.
    origin_id   = "ALB-Origin"           # Unique identifier for this origin.

    # Configuration specific to a custom origin (ALB in this case).
    custom_origin_config {
      http_port              = 80          # ALB HTTP port.
      https_port             = 443         # ALB HTTPS port.
      origin_protocol_policy = "http-only" # CloudFront connects using HTTP only.
      origin_ssl_protocols   = ["TLSv1.2"] # Allowed SSL protocols if HTTPS is used.
    }
  }

  # Configure cache behavior for requests to the ALB.
  default_cache_behavior {
    target_origin_id       = "ALB-Origin"        # Route requests to the ALB origin.
    viewer_protocol_policy = "redirect-to-https" # Redirect HTTP to HTTPS.
    allowed_methods        = ["GET", "HEAD"]     # Allow GET and HEAD requests.
    cached_methods         = ["GET", "HEAD"]     # Cache responses for GET and HEAD.
    compress               = true                # Enable compression for better performance.

    forwarded_values {
      query_string = false # Do not forward query strings.
      cookies {
        forward = "none" # Do not forward cookies.
      }
    }
    min_ttl     = 0    # Minimum TTL.
    max_ttl     = 3600 # Maximum TTL (1 hour).
    default_ttl = 3600 # Default TTL (1 hour).
  }

  # Configure viewer certificate for HTTPS.
  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.default_certificate.arn # ACM certificate ARN.
    ssl_support_method       = "sni-only"                                  # Use SNI.
    minimum_protocol_version = "TLSv1.2_2021"                              # Enforce minimum TLS version.
  }

  enabled = true # Enable the distribution.

  # No geographic restrictions.
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Tags for organization and identification.
  tags = {
    Name        = "${var.environment_prod}-distribution-app" # Name tag using production environment variable.
    Environment = "${var.environment_prod}"                  # Environment tag.
  }
}
