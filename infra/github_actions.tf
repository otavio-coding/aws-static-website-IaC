/* Create IAM role for Github Actions using OIDC a S3 deploy policy and than attach
it to the user */
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
        StringEquals = {
          "token.actions.githubusercontent.com:sub" = "repo:${var.github_account_id}/:${var.github_repo}:ref:refs/heads/main",
          "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
        }
      }
    }]
  })
}


resource "aws_iam_role_policy" "s3_deploy_policy" {
  role = aws_iam_role.github_oidc_role.name
  policy = data.aws_iam_policy_document.s3_deploy_policy.json
}

data "aws_iam_policy_document" "s3_deploy_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.website.id}/*"]
  }  
}