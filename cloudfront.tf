# resource "aws_cloudfront_origin_access_identity" "default_cloudfront_oai" {
#   comment = "OAI for accessing S3 content"
# }

resource "aws_cloudfront_distribution" "default_website_distribution" {

  enabled = true
  #is_ipv6_enabled = true
  price_class = "PriceClass_100"
  aliases     = ["www.dolapoadeeyocv.com"]

  viewer_certificate {
    acm_certificate_arn = aws_acm_certificate.default_certificate.arn
    ssl_support_method  = "sni-only"
  }

  origin {
    domain_name = aws_s3_bucket.default_website_bucket.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.default_website_bucket.bucket

    # s3_origin_config {
    #   origin_access_identity = aws_cloudfront_origin_access_identity.default_cloudfront_oai.id
    # }
  }

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.default_website_bucket.bucket
    viewer_protocol_policy = "redirect-to-https"

    forwarded_values {
      query_string = false


      cookies {
        forward = "none"
      }
    }
    min_ttl     = 0
    max_ttl     = 3600
    default_ttl = 3600
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name = "default-distribution"
  }
}

resource "aws_cloudfront_origin_access_control" "default_cloudfront_oai" {
  name                              = "default_cloudfront_oai"
  description                       = "default_cloudfront_oai"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

