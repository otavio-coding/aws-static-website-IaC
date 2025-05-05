/* 
This file contains IaC that creates:
  - The 'www.example.com' bucket:
    - This is the main bucket that will store the index.html;
    - Configuration for static website hosting;
    - Public read permitions;
    - Permitions to allow Github Actions deployment.
    
  - The 'example.com' bucket
    - This buvket is configured will redirect all requests to the 'www.example.com' bucket. 
*/


/* The following lines create and configure the 'www.example.com' */
resource "aws_s3_bucket" "www" {
  bucket        = "www.${var.registered_domain}"
  force_destroy = true
}

/* Configuration to enable static hosting.*/
resource "aws_s3_bucket_website_configuration" "www" {
  bucket = aws_s3_bucket.www.id
  index_document {
    suffix = "index.html"
  }
}

/* Allow public-read policies */
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket              = aws_s3_bucket.www.id
  block_public_policy = false # False value allows public access policies.
}

/* Create policy  document to allow github actions IAM role to  List, Put and
Delete objects. */
data "aws_iam_policy_document" "github_actions_deploy" {
  statement {
    sid    = "GithubActionsDeploy"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["${aws_iam_role.github_oidc_role.arn}"]
    }
    actions = [
      "s3:PutObject",
      "s3:DeleteObject",
      "s3:ListBucket"
    ]
    resources = [
      "${aws_s3_bucket.www.arn}/*", # Objects ARN (for Put/Delete) 
      "${aws_s3_bucket.www.arn}"    # Bucket ARN (for ListBucket)
    ]
  }
}

/* Create policy document to allow public read. Granting access from
the web to read the public files. */
data "aws_iam_policy_document" "public_read" {
  statement {
    sid    = "PublicRead"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.www.arn}/*"]
  }
}

/* Combine policy documents created above into a single one */
data "aws_iam_policy_document" "www_bucket_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.public_read.json,
    data.aws_iam_policy_document.github_actions_deploy.json
  ]

}

/* Finally, add policy to the bucket */
resource "aws_s3_bucket_policy" "www_bucket_policy" {
  bucket     = aws_s3_bucket.www.id
  policy     = data.aws_iam_policy_document.www_bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.public_access] # 'depends_on' ensures public access is allowed first!
}


/* The following lines create and configure the 'example.com' */
resource "aws_s3_bucket" "root" {
  bucket        = var.registered_domain
  force_destroy = true
}

/* Configuration to redirect all requests to www.example.com */
resource "aws_s3_bucket_website_configuration" "root" {
  bucket = aws_s3_bucket.root.id

  redirect_all_requests_to {
    host_name = aws_s3_bucket.www.bucket
    protocol  = "http"
  }
}
