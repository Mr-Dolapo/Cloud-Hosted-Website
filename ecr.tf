####################################################################################################
# ECR Repository: snake-app
#
# This resource creates an ECR repository for the "snake-app" containerized application.
# It enables image scanning on push and sets the image tag mutability to "MUTABLE".
####################################################################################################
resource "aws_ecr_repository" "snake-app" {
  name                 = "snake-app"  # Repository name for the snake-app
  image_tag_mutability = "MUTABLE"    # Allows tags to be overwritten (mutable) instead of immutable

  image_scanning_configuration {
    scan_on_push = true  # Automatically scan images when they are pushed to the repository
  }

  tags = {
    Name        = "${var.environment_prod}-ecr-snake-app"  # Tag to identify repository and environment
    Environment = "${var.environment_prod}"                # Environment tag for cost allocation and organization
  }
}

####################################################################################################
# ECR Repository: app
#
# This resource creates an ECR repository for the "app" containerized application.
# Similar to the snake-app repository, image scanning on push is enabled, and tags are mutable.
####################################################################################################
resource "aws_ecr_repository" "app" {
  name                 = "app"        # Repository name for the main application
  image_tag_mutability = "MUTABLE"    # Allow mutable tags for the repository

  image_scanning_configuration {
    scan_on_push = true  # Enable image scanning upon push
  }

  tags = {
    Name        = "${var.environment_prod}-ecr-app"  # Tag for repository identification
    Environment = "${var.environment_prod}"          # Environment tag
  }
}

####################################################################################################
# ECR Repository: mongodb
#
# This resource creates an ECR repository for the MongoDB container.
# It ensures images are scanned on push and the image tags remain mutable.
####################################################################################################
resource "aws_ecr_repository" "mongodb" {
  name                 = "mongodb"    # Repository name for MongoDB
  image_tag_mutability = "MUTABLE"    # Set tag mutability to allow updates

  image_scanning_configuration {
    scan_on_push = true  # Enable image scanning on push to detect vulnerabilities
  }

  tags = {
    Name        = "${var.environment_prod}-ecr-mongodb"  # Tag with environment information for MongoDB repository
    Environment = "${var.environment_prod}"
  }
}

####################################################################################################
# ECR Repository: mongo-express
#
# This resource creates an ECR repository for the mongo-express container,
# which is typically used as a web-based admin interface for MongoDB.
# It enables image scanning on push and allows mutable image tags.
####################################################################################################
resource "aws_ecr_repository" "mongo_express" {
  name                 = "mongo-express"  # Repository name for mongo-express
  image_tag_mutability = "MUTABLE"        # Enable mutable image tags

  image_scanning_configuration {
    scan_on_push = true  # Enable scanning of images upon push for vulnerability checks
  }

  tags = {
    Name        = "${var.environment_prod}-ecr-mongo-express"  # Tag for identification and environment grouping
    Environment = "${var.environment_prod}"
  }
}
