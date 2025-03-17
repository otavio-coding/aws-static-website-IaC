/* Create S3 bucket. */
resource "aws_s3_bucket" "website" {
  bucket        = var.bucket_name
  force_destroy = true
}

/* Configure it to deliver the frontend. */
resource "aws_s3_bucket_website_configuration" "website" {
  bucket = aws_s3_bucket.website.id
  index_document {
    suffix = "index.html"
  }
}

/* POLICIES */
/* Allow public-read policies */
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website.id
  block_public_policy     = false # False value allows public access policies.
}

/* Create policy  document to allow github actions IAM role to  List, Put and
Delete objects. */
data "aws_iam_policy_document" "github_actions_deploy" {
  statement {
    sid = "GithubActionsDeploy"
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

/* Create policy document to allow public read. Granting access from
the web to read the public files. */
data "aws_iam_policy_document" "public_read" {
  statement {
    sid = "PublicRead"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]
  }
}

/* Combine policy documents created above into a single one */
data "aws_iam_policy_document" "website_bucket_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.public_read.json,
    data.aws_iam_policy_document.github_actions_deploy.json
  ]
  
}

/* Finally, add policy to bucket */
resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.website_bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.public_access] # 'depends_on' ensures public access is allowed first!
}

/* Output S3 name */
output "s3_bucket_name" {
  value = aws_s3_bucket.website.id
}