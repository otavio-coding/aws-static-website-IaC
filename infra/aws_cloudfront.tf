/*
  This file contains resources related to the CloudFront distribution of our site.
*/

data "aws_cloudfront_cache_policy" "cache_policy" {
  name = "Managed-CachingOptimized"
}

resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = aws_s3_bucket.subdomain.bucket_regional_domain_name
    origin_id   = aws_s3_bucket.subdomain.id
  }

  enabled             = true
  comment             = "Awesome CloudFront distribution"
  default_root_object = "index.html"

  aliases = ["${var.subdomain}.${var.registered_domain}"]

  default_cache_behavior {
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    target_origin_id       = aws_s3_bucket.subdomain.id
    cache_policy_id        = data.aws_cloudfront_cache_policy.cache_policy.id
    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn = data.aws_acm_certificate.issued.arn
    ssl_support_method  = "sni-only"
  }
}