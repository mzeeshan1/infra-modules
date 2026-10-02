###############################################################################
# GitHub OIDC Provider
###############################################################################

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    "6938fd4d98bab03faadb97b34396831e3780aea1"
  ]

  tags = {
    ManagedBy = "terraform"
  }
}


###############################################################################
# GitHub Actions - subscription-reminder
###############################################################################

module "github_actions_sub_rem_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "~> 5.0"

  name = "github-actions-sub-rem"

  provider_url = aws_iam_openid_connect_provider.github.url

  subjects = var.github_oidc_subrem_subjects

  policies = {
    GitHubActions = aws_iam_policy.github_actions_sub_rem.arn
  }

  tags = {
    ManagedBy  = "terraform"
    Repository = "mzeeshan1/subscription-reminder"
  }
}


###############################################################################
# GitHub Actions - infra
###############################################################################

module "github_actions_infra_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "~> 5.0"

  name = "github-actions-infra"

  provider_url = aws_iam_openid_connect_provider.github.url

  subjects = var.github_oidc_infra_subjects

  policies = {
    AssumeTerraform = aws_iam_policy.github_actions_infra_assume_terraform.arn
  }

  tags = {
    ManagedBy  = "terraform"
    Repository = "mzeeshan1/infra"
  }
}


###############################################################################
# Policy: infra GitHub role can assume Terraform role
###############################################################################

resource "aws_iam_policy" "github_actions_infra_assume_terraform" {
  name = "github-actions-infra-assume-terraform"

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Action = [
          "sts:AssumeRole"
        ]


        Resource = [
          var.terraform_role_arn
        ]

      }
    ]
  })

  tags = {
    ManagedBy = "terraform"
  }
}


###############################################################################
# Policy: subscription-reminder GitHub Actions
###############################################################################

resource "aws_iam_policy" "github_actions_sub_rem" {
  name = "github-actions-sub-rem"

  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = local.policy_statements
  })

  tags = {
    ManagedBy = "terraform"
  }
}
