# Infrastructure as Code (IaC) for Static Website Hosting on AWS S3
## Demo: https://dev.otaviocoding.click
This project provisions a static website hosting infrastructure with public read permitions on AWS S3 using Terraform. It also includes a GitHub Actions workflow for continuous integration (CI), so every time you push to this repository, the changes are tested and the `public/` folder content is automatically deployed to the bucket. 

## Dependencies

- Terraform v1.10.5

## Prerequisites

### For AWS Infrastructure
- Valid AWS credentials
- A registered domain `example.com` with an existing hosted zone in Route 53  
- An ACM-Amazon Certificate Manager issued certificate for the domain name `*.example.com`. 
- Your Route 53 Hosted Zone must contain:
  - The certificate CNAME record.
  - NS-Name Server record and a SOA-Stat of Authority record (if you bought your domain from Route 53 domain 
  registry services the hosted zone will be created automatically with both).

### For GitHub Actions CI

- Set the following repository secrets in GitHub:
  - `AWS_ACCOUNT_ID`
  - `AWS_REGION`
  - `AWS_REGISTERED_DOMAIN`  
  These variables are required in the `deploy.yaml` workflow file.

## AWS Resources Created after `terraform apply`

- **An S3 Bucket**:
  - A bucket for the `www` subdomain (e.g., `www.example.com`) which stores the website content

- **A CloudFront distribution**:
  - A cloudfront distribution that will serve the `index.html` from the s3 bucket using a HTTPS connection.

- **Route 53 Records**:
  - Alias records pointing from `subdomain.example.com` to the CloudFront distribution, created in an existing hosted zone. 

- **IAM Role**:
  - Configured with OIDC and can be assumed by GitHub Actions for secure, short-lived access

## How to use it 

1. Set the terraform variable on a `infra/.tfvars` file:
```
registered_domain = "example.com"
acm_domain_name   = "*.example.com"
subdomain         = "dev"
aws_account_id    = <your-aws-account-id>
github_account_id = "<your-github-id>"
github_repo       = "<github-repo-name>" 
```
2. Run `terraform apply`. This step is necessary to create the IAM role and permissions that allow GitHub Actions to deploy to your S3 bucket.
3. Update the `index.html` file and push your changes to main to trigger the CI. The contents of the `public/` folder will be deployed into your S3 bucket.
4. That's it, your static website is up and running on your registered domain (`www.example.com` or `example.com`)

## Reference Documentation

- [Terraform AWS Provider Docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)  
- [Use IAM Roles to Connect GitHub Actions to AWS](https://aws.amazon.com/blogs/security/use-iam-roles-to-connect-github-actions-to-actions-in-aws/)  
- [GitHub Docs: Configuring OIDC in AWS](https://docs.github.com/en/actions/security-for-github-actions/security-hardening-your-deployments/configuring-openid-connect-in-amazon-web-services)
