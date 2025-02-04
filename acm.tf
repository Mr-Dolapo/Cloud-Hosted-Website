# Define an ACM certificate resource for the domain dolapoadeeyocv.com
resource "aws_acm_certificate" "default_certificate" {
  # The primary domain for the certificate.
  domain_name = "dolapoadeeyocv.com"
  # Use DNS validation to prove ownership of the domain.
  validation_method = "DNS"

  # Specify additional domains (Subject Alternative Names) covered by the certificate.
  subject_alternative_names = [
    "www.dolapoadeeyocv.com",
    "app.dolapoadeeyocv.com"
  ]

  # Lifecycle settings to ensure smooth certificate replacement.
  lifecycle {
    # Creates a new certificate before destroying the old one, reducing downtime.
    create_before_destroy = true
  }

  # Tag the certificate resource for easier management and identification.
  tags = {
    Name        = "${var.environment_prod}-certificate"
    Environment = "${var.environment_prod}"
  }
}
