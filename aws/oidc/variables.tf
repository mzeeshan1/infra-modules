variable "github_oidc_subjects" {
  description = "GitHub OIDC subjects allowed to assume the GitHub Actions IAM role."
  type        = list(string)
  default     = []
}

variable "github_actions_policy_statements" {
  description = "Additional IAM policy statements for GitHub Actions."
  type        = list(any)
  default     = []
}
