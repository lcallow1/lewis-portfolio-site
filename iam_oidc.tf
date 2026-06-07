# ── GitHub Actions OIDC provider ──────────────────────────────────────────────

resource "aws_iam_openid_connect_provider" "github" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# ── IAM role for GitHub Actions ───────────────────────────────────────────────

resource "aws_iam_role" "github_actions_deploy" {
  name = "github-actions-portfolio-deploy"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = aws_iam_openid_connect_provider.github.arn
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "token.actions.githubusercontent.com:aud" = "sts.amazonaws.com"
          }
          StringLike = {
            "token.actions.githubusercontent.com:sub" = "repo:lcallow1/lewis-portfolio-site:ref:refs/heads/main"
          }
        }
      }
    ]
  })

  tags = {
    Project     = "lewis-portfolio-site"
    Environment = "prod"
    ManagedBy   = "terraform"
  }
}

# ── IAM policy: what the pipeline is allowed to do ────────────────────────────

resource "aws_iam_policy" "github_actions_deploy" {
  name        = "github-actions-portfolio-deploy"
  description = "Allows GitHub Actions to sync S3 and invalidate CloudFront"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          module.site.bucket_arn,
          "${module.site.bucket_arn}/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "cloudfront:CreateInvalidation"
        Resource = aws_cloudfront_distribution.site.arn
      }
    ]
  })
}

# ── Attach policy to role ──────────────────────────────────────────name────────

resource "aws_iam_role_policy_attachment" "github_actions_deploy" {
  role       = aws_iam_role.github_actions_deploy.name
  policy_arn = aws_iam_policy.github_actions_deploy.arn
}

# ── Output the role ARN ────────────────────────────────────────────────────────

output "github_actions_role_arn" {
  description = "The IAM role ARN for GitHub Actions to assume."
  value       = aws_iam_role.github_actions_deploy.arn
}
