variable "registered_domain" {
  description = "Your registered domain (example.com). It must associated with an existing Route 53 hosted zone."
  type        = string
}

variable "subdomain" {
  description = "Desired subdomain (default value is www)."
  type        = string
  default     = "www"
}

variable "acm_domain_name" {
  description = "The main domain name of the AWS Certificate Manager issued certificate (example.com or *.example.com)"
  type        = string
}
variable "aws_account_id" {
  description = "AWS account ID"
  type        = number
  sensitive   = true
}

variable "github_account_id" {
  description = "Your github ID"
  type        = string
}

variable "github_repo" {
  description = "The repo you want to sync files with AWS S3"
  type        = string
}