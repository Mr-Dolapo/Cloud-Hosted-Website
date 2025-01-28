resource "aws_cloudfront_origin_access_control" "default_cloudfront_oac" {
  name                              = "default_cloudfront_oai"
  description                       = "default_cloudfront_oai"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}


resource "aws_cloudfront_distribution" "default_website_distribution" {

  default_root_object = "index.html"
  enabled             = true
  #is_ipv6_enabled = true
  price_class = "PriceClass_100"
  aliases     = ["dolapoadeeyocv.com", "www.dolapoadeeyocv.com"]

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.default_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }

  origin {
    domain_name              = aws_s3_bucket.default_website_bucket.bucket_regional_domain_name
    origin_id                = aws_s3_bucket.default_website_bucket.bucket
    origin_access_control_id = aws_cloudfront_origin_access_control.default_cloudfront_oac.id
  }

  origin {
    domain_name = aws_lb.app_lb.dns_name  
    origin_id   = "ecs-origin"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"  
      origin_ssl_protocols   = ["TLSv1.2"]  
    }
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

  
  ordered_cache_behavior {
    path_pattern           = "/app/*"
    target_origin_id       = "ecs-origin"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "allow-all"
    compress               = true

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