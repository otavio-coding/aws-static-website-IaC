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

/* Create a public-read policy to the bucket. Instead of defining the
policy in the resource block, it'll be defined in a data block. */
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.website.id
  block_public_policy     = false # Allow public policies.
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.public_read.json
  depends_on = [aws_s3_bucket_public_access_block.public_access] 
  # 'depends_on' ensures public access is allowed first!
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