module "github_actions_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "~> 5.0"

  name     = "github-actions"
  subjects = var.github_oidc_subjects

  policies = {
    GitHubActions = aws_iam_policy.github_actions.arn
  }

  tags = {
    ManagedBy = "terraform"
  }
}

resource "aws_iam_policy" "github_actions" {
  name = "github-actions"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.policy_statements
  })
}


resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  tags = {
    ManagedBy = "terraform"
  }

}

