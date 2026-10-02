variable "github_oidc_subjects" {
  description = "GitHub OIDC subjects allowed to assume the GitHub Actions IAM role."
  type        = list(string)
  default     = []
}
