/* Create IAM user for Github Actions a S3 deploy policy and than attach
it to the user */
resource "aws_iam_user" "github_actions" {
  name = "github-actions-user"
}

resource "aws_iam_policy" "s3_deploy_policy" {
  name        = "S3DeployPolicy"
  description = "Allows Github Actions to deploy to the S3"
  policy      = data.aws_iam_policy_document.s3_deploy_policy.json
}

data "aws_iam_policy_document" "s3_deploy_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:PutObject", "s3:DeleteObject"]
    resources = ["arn:aws:s3:::${aws_s3_bucket.website.id}/*"]
  }
}

resource "aws_iam_user_policy_attachment" "attach_policy" {
  user       = aws_iam_user.github_actions.name
  policy_arn = aws_iam_policy.s3_deploy_policy.arn
}
