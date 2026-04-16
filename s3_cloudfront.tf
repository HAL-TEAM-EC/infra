# 1. S3 bucket to store frontend static files (HTML, JS, CSS)
resource "aws_s3_bucket" "frontend" {
  bucket = "hal-ec-frontend-storage-${random_id.bucket_suffix.hex}"
}

# 2. Origin Access Control (OAC) to allow CloudFront to access private S3 bucket
resource "aws_cloudfront_origin_access_control" "main" {
  name                              = "s3-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# 3. CloudFront Distribution (CDN) for fast global content delivery
resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name              = aws_s3_bucket.frontend.bucket_regional_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.main.id
    origin_id                = "S3-Frontend"
  }

  enabled             = true
  is_ipv6_enabled     = true
  default_root_object = "index.html"

  # Default cache behavior for static content
  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-Frontend"

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    # Force HTTPS for better security
    viewer_protocol_policy = "redirect-to-https"
  }

  # No geographic restrictions for users
  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  # Use default CloudFront SSL certificate (*.cloudfront.net)
  viewer_certificate {
    cloudfront_default_certificate = true
  }

  tags = {
    Name = "hal-ec-frontend-cdn"
  }
}

# 4. S3 Bucket Policy to allow CloudFront (OAC) to read files
resource "aws_s3_bucket_policy" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "AllowCloudFrontServicePrincipalReadOnly"
        Effect    = "Allow"
        Principal = {
          Service = "cloudfront.amazonaws.com"
        }
        Action   = "s3:GetObject"
        Resource = "${aws_s3_bucket.frontend.arn}/*"
        Condition = {
          StringEquals = {
            "AWS:SourceArn" = aws_cloudfront_distribution.main.arn
          }
        }
      }
    ]
  })
}