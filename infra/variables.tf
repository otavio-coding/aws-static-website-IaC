variable "bucket_name" {
  description = "Name of the S3 bucket"
  type        = string
}

variable "aws_account_id" {
  description = "AWS account ID"
  type = number
}

variable "github_account_id" {
  description = "Your github ID"
  type = string
}

variable "github_repo" {
  description = "The repo you want to sync files with AWS S3"
  type = string
}