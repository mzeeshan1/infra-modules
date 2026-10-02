module "github_actions_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role"
  version = "~> 6.0"

  name = "github-actions"

  enable_github_oidc = true

  oidc_wildcard_subjects = var.github_oidc_subjects

  policies = {
    ECR = aws_iam_policy.github_ecr.arn
  }

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_iam_policy" "github_ecr" {
  name = "github-actions-ecr"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart"
        ]
        Resource = aws_ecr_repository.my_app.arn
      }
    ]
  })
}
