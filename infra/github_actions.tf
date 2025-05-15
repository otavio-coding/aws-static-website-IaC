/* 
This file contains IaC that creates:
  - An IAM role to be assumed by Github Actions using OIDC 
  - A IAM policy with deploy permitions;
  - OIDC settings for Github.
*/

/* The following lines create an IAM role to be assumed by Github Actions workflows.
OIDC allows secure, short-lived access to AWS without storing credentials.*/
resource "aws_iam_role" "github_oidc_role" {
  name = "GithubActionsRole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Federated = "arn:aws:iam::${var.aws_account_id}:oidc-provider/token.actions.githubusercontent.com"
      }
      Action = "sts:AssumeRoleWithWebIdentity"
      Condition = {
        StringLike = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_account_id}/${var.github_repo}:*",
        }
        StringEquals = {
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}

/* Here is a policy that allows the Github Actions role update the bucket content.*/
data "aws_iam_policy_document" "s3_deploy_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject", "s3:ListBucket"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.subdomain.id}/*"]
  }
}
resource "aws_iam_role_policy" "s3_deploy_policy" {
  role   = aws_iam_role.github_oidc_role.name
  policy = data.aws_iam_policy_document.s3_deploy_policy.json
}


/* The following lines set up an OIDC for secure access to AWS from Github workflows.*/
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1", "1c58a3a8518e8759bf075b76b750d4f2df264fcd"]
  client_id_list  = ["sts.amazonaws.com"]
}