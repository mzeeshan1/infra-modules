locals {
  default_policy_statements = [
    {
      Effect = "Allow"

      Action = [
        "ecr:GetAuthorizationToken"
      ]

      Resource = [
        "*"
      ]
    },
  ]

  policy_statements = concat(
    local.default_policy_statements,
    var.github_actions_policy_statements
  )
}
