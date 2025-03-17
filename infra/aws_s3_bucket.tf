/* Create S3 bucket and configure it to deliver the frontend. */
resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true
}


resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  index_document {
    suffix = "index.html"
  }
}

/* Add a Github actions bucket policy*/

/* 1. Create policy to allow github actions role to  List, Put and
Delete objects. */
resource "aws_s3_bucket_policy" "github_actions_deploy" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.github_actions_deploy.json
}

data "aws_iam_policy_document" "github_actions_deploy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.github_oidc_role.arn}"]
    }
    actions   = [
      "s3:PutObject", 
      "s3:DeleteObject", 
      "s3:ListBucket"
      ]
    resources = [
      "${aws_s3_bucket.website.arn}/*", # Objects ARN (for Put/Delete) 
      "${aws_s3_bucket.website.arn}" # Bucket ARN (for ListBucket)
    ]
  }
}

/* Add a public-read policy to the bucket.*/

/*1. Allow public policies */
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website.id
  block_public_policy     = false # Allow public policies.
}

/* 2. Create policy to allow public read. Thus granting access from
the web to read the public files. */
resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.public_read.json
  depends_on = [aws_s3_bucket_public_access_block.public_access] # 'depends_on' ensures public access is allowed first!
}

data "aws_iam_policy_document" "public_read" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]
  }
}

/* Output S3 name */
output "s3_bucket_name" {
  value = aws_s3_bucket.website.id
}