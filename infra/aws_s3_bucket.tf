/* 
This file contains IaC that creates:
  - The 'subdomain.example.com' bucket:
    - This is the bucket that will store the index.html;
    - Public read permitions;
    - Permitions to allow Github Actions deployment.
*/


/* The following lines create and configure the 'subdomain.example.com' */
resource "aws_s3_bucket" "subdomain" {
  bucket        = "${var.subdomain}.${var.registered_domain}"
  force_destroy = true
}

/* Allow public-read policies */
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket              = aws_s3_bucket.subdomain.id
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
      "${aws_s3_bucket.subdomain.arn}/*", # Objects ARN (for Put/Delete) 
      "${aws_s3_bucket.subdomain.arn}"    # Bucket ARN (for ListBucket)
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
    resources = ["${aws_s3_bucket.subdomain.arn}/*"]
  }
}

/* Combine policy documents created above into a single one */
data "aws_iam_policy_document" "subdomain_bucket_policy" {
  source_policy_documents = [
    data.aws_iam_policy_document.public_read.json,
    data.aws_iam_policy_document.github_actions_deploy.json
  ]

}

/* Finally, add policy to the bucket */
resource "aws_s3_bucket_policy" "subdomain_bucket_policy" {
  bucket     = aws_s3_bucket.subdomain.id
  policy     = data.aws_iam_policy_document.subdomain_bucket_policy.json
  depends_on = [aws_s3_bucket_public_access_block.public_access] # 'depends_on' ensures public access is allowed first!
}