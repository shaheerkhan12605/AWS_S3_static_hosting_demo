# Terraform Provider 

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "eu-central-1"
}

resource "aws_s3_bucket" "test_bucket_sk" {
  bucket = "shaheer-gogift-cfn-test"
  tags = {
    Name        = "shaheer-gogift-cfn-test"
    Application = "GoGift"
    Owner       = "Shaheer"
    Description = "This Bucket is created manually and imported from terraform"
  }
  tags_all = {
    Name        = "shaheer-gogift-cfn-test"
    Application = "GoGift"
    Owner       = "Shaheer"
    Description = "This Bucket is created manually and imported from terraform"

  }
}

resource "aws_s3_bucket_ownership_controls" "test_bucket_sk_control" {
  bucket = aws_s3_bucket.test_bucket_sk.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

locals {
  s3_origin_id = "static-hosting"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.test_bucket_sk.bucket_regional_domain_name
    origin_id   = local.s3_origin_id
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "Some comment"
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
    forwarded_values {
      headers                 = []
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }
  }

  # Cache behavior with precedence 0
  ordered_cache_behavior {
    path_pattern     = "/content/immutable/*"
    allowed_methods  = ["GET", "HEAD", "OPTIONS"]
    cached_methods   = ["GET", "HEAD", "OPTIONS"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      headers                 = []
      query_string            = false
      query_string_cache_keys = []

      cookies {
        forward           = "none"
        whitelisted_names = []
      }
    }

    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    compress               = true
    viewer_protocol_policy = "allow-all"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Name        = "shaheer-gogift-cfn-test"
    Application = "GoGift"
    Owner       = "Shaheer"
    Description = "This Bucket is created manually and imported from terraform"
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}