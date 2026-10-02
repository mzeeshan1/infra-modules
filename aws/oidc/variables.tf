variable "github_oidc_subrem_subjects" {
  type = list(string)

  default = [
    "mzeeshan1/subscription-reminder:ref:refs/heads/main",
    "mzeeshan1/subscription-reminder:ref:refs/tags/*",
  ]
}

variable "github_oidc_infra_subjects" {
  type = list(string)

  default = [
    "mzeeshan1/infra:ref:refs/heads/main",
    "mzeeshan1/infra:pull_request",
  ]
}
variable "github_actions_subrem_policy_statements" {
  description = "Additional IAM policy statements for GitHub Actions."
  type        = list(any)
  default     = []
}


variable "terraform_role_arn" {
  description = "ARN of the manually managed Terraform IAM role."
  type        = string
}
