###################################################################################################
# S3 Bucket for Website Hosting
#
# This resource creates an S3 bucket that will be used to host the website files.
# It is tagged for the production environment using the var.environment_prod variable.
###################################################################################################
resource "aws_s3_bucket" "default_website_bucket" {
  bucket = "dolapo-website-bucket"  # The unique name of the S3 bucket

  tags = {
    Name        = "${var.environment_prod}-website-bucket"  # Tag with the environment and bucket purpose
    Environment = "${var.environment_prod}"                 # Environment tag for cost allocation and organization
  }
}

###################################################################################################
# S3 Bucket Versioning
#
# This resource enables versioning on the S3 bucket to preserve, store, and recover previous
# versions of objects.
###################################################################################################
resource "aws_s3_bucket_versioning" "versioning_example" {
  bucket = aws_s3_bucket.default_website_bucket.id  # Associate versioning with the created bucket

  versioning_configuration {
    status = "Enabled"  # Enable versioning on the bucket
  }
}

###################################################################################################
# S3 Bucket Server-Side Encryption Configuration
#
# This resource configures server-side encryption on the bucket using the AES256 algorithm.
###################################################################################################
resource "aws_s3_bucket_server_side_encryption_configuration" "default_website_bucket_encryption" {
  bucket = aws_s3_bucket.default_website_bucket.id  # Target bucket for encryption configuration

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"  # Use AES256 for encryption at rest
    }
  }
}

###################################################################################################
# S3 Object: index.html
#
# This resource uploads the index.html file from the local "Website" directory to the S3 bucket.
# It sets the content type to text/html so browsers render it correctly.
###################################################################################################
resource "aws_s3_object" "default_index_html" {
  bucket       = aws_s3_bucket.default_website_bucket.id  # Target bucket for the object
  key          = "index.html"                             # The key (file name) in the bucket
  source       = "Website/index.html"                     # Local path to the index.html file
  content_type = "text/html"                              # Type of file
}

###################################################################################################
# S3 Object: 404.html
#
# This resource uploads a custom error page (404.html) to the S3 bucket.
# It sets the content type to text/html.
###################################################################################################
resource "aws_s3_object" "default_error_html" {
  bucket       = aws_s3_bucket.default_website_bucket.id  # Target bucket for the object
  key          = "404.html"                               # The key for the error page
  source       = "Website/404.html"                       # Local path to the 404.html file
  content_type = "text/html"                              # Type of error page
}

###################################################################################################
# S3 Bucket Website Configuration
#
# This resource configures the S3 bucket for website hosting.
# It defines the default index document and error document.
###################################################################################################
resource "aws_s3_bucket_website_configuration" "default_website_configuration" {
  bucket = aws_s3_bucket.default_website_bucket.id  # The bucket for which the website configuration is applied

  index_document {
    suffix = "index.html"  # When a user visits the root of the website, serve index.html
  }

  error_document {
    key = "Website/error.html"  # Specify the error page (note: ensure this key matches an object in the bucket)
  }
}

###################################################################################################
# S3 Bucket Policy
#
# This resource attaches a bucket policy to the S3 bucket to allow CloudFront access.
# The policy is generated from a template file (s3_policy.json.tpl) using the templatefile() function.
###################################################################################################
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.default_website_bucket.id  # Target bucket for the policy

  # Generate the policy JSON using a template file and variables:
  # - bucket_arn: The ARN of the S3 bucket.
  # - cloudfront_arn: The ARN of the CloudFront distribution.
  policy = templatefile("s3_policy.json.tpl", {
    bucket_arn     = aws_s3_bucket.default_website_bucket.arn
    cloudfront_arn = aws_cloudfront_distribution.default_website_distribution.arn
  })
}
