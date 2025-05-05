/*
  This file defines the infrastructure to create Route 53 alias records 
  for both the root domain (example.com) and the www subdomain (www.example.com),
  pointing them to their respective S3 static website hosting buckets.

  Prerequisites:
  - The domain must be registered.
  - A corresponding Route 53 hosted zone must already exist.
*/

data "aws_route53_zone" "hosted_zone" {
  name = var.registered_domain
}

data "aws_s3_bucket" "www" {
  bucket = aws_s3_bucket.www.bucket
}

resource "aws_route53_record" "www" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "www.${var.registered_domain}"
  type    = "A"
  
  alias {
    name = data.aws_s3_bucket.www.website_domain
    zone_id = data.aws_s3_bucket.www.hosted_zone_id
    evaluate_target_health = false
  }
}

data "aws_s3_bucket" "root" {
  bucket = aws_s3_bucket.root.bucket
}

resource "aws_route53_record" "root" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = var.registered_domain
  type    = "A"
  
  alias {
    name = data.aws_s3_bucket.root.website_domain
    zone_id = data.aws_s3_bucket.root.hosted_zone_id
    evaluate_target_health = false
  }
}