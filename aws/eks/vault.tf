################################################################################
# Vault - KMS auto-unseal
################################################################################
# Codifies resources that were created manually (see vault-resources-manual-installation/):
# - KMS key "alias/vault-auto-unseal" (d9c47d0f-074d-45a3-b82a-2e1e6ba2e742)
# - IAM role "VaultKMSAutoUnsealRole" / policy "VaultKMSAutoUnseal"
# - Pod identity association for the "vault" service account in the "vault" namespace

locals {
  vault_assocations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.vault
    if v.enable_pod_identity_associations && v.pod_identity_associations.vault.enabled
  }
}

resource "aws_kms_key" "vault_auto_unseal" {
  count       = length(local.vault_assocations) > 0 ? 1 : 0
  description = "Vault auto-unseal"
}

resource "aws_kms_alias" "vault_auto_unseal" {
  count         = length(local.vault_assocations) > 0 ? 1 : 0
  name          = "alias/vault-auto-unseal"
  target_key_id = aws_kms_key.vault_auto_unseal[0].key_id
}

resource "aws_iam_role" "vault_kms_auto_unseal" {
  count       = length(local.vault_assocations) > 0 ? 1 : 0
  name        = "VaultKMSAutoUnsealRole"
  description = "Allows Vault pods to use AWS KMS for auto-unseal"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AllowEksAuthToAssumeRoleForPodIdentity"
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
      }
    ]
  })
}

resource "aws_iam_policy" "vault_kms_auto_unseal" {
  count = length(local.vault_assocations) > 0 ? 1 : 0
  name  = "VaultKMSAutoUnseal"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:DescribeKey",
        ]
        Resource = aws_kms_key.vault_auto_unseal[0].arn
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "vault_kms_auto_unseal" {
  count      = length(local.vault_assocations) > 0 ? 1 : 0
  role       = aws_iam_role.vault_kms_auto_unseal[0].name
  policy_arn = aws_iam_policy.vault_kms_auto_unseal[0].arn
}

resource "aws_eks_pod_identity_association" "vault" {
  for_each = local.vault_assocations

  cluster_name    = each.key
  namespace       = each.value.namespace
  service_account = each.value.service_account_name
  role_arn        = aws_iam_role.vault_kms_auto_unseal[0].arn
  tags            = each.value.tags
}
