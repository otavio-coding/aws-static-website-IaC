/*
  This file defines the infrastructure to create Route 53 alias records 
  for both the root domain (example.com) routing it to the CloudFront distribution.
*/

data "aws_route53_zone" "hosted_zone" {
  name = var.registered_domain # hosted zone name is the same as your registered domain
}

data "aws_s3_bucket" "subdomain" {
  bucket = aws_s3_bucket.subdomain.bucket
}

resource "aws_route53_record" "subdomain" {
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  name    = "${var.subdomain}.${var.registered_domain}"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.s3_distribution.domain_name
    zone_id                = aws_cloudfront_distribution.s3_distribution.hosted_zone_id
    evaluate_target_health = false
  }

  depends_on = [aws_cloudfront_distribution.s3_distribution]
}