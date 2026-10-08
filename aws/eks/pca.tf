################################################################################
# AWS Private CA - root CA used by cert-manager via AWSPCAClusterIssuer
################################################################################
# Codifies resources that were created manually (see vault-resources-manual-installation/):
# - ACM Private CA "vault-private-ca" (c10a4734-c58d-4791-b26f-e9a9d44f97ef)
# - IAM role "CertManagerPrivateCARole" (AWSPrivateCAConnectorForKubernetesPolicy)
# - The "aws-privateca-connector-for-kubernetes" EKS addon and its pod identity association
#
# The CA's self-signed root certificate was installed manually and is not managed here:
# re-running the install on an already-ACTIVE root CA is not an idempotent Terraform
# operation, so this resource only tracks the certificate authority itself.

resource "aws_acmpca_certificate_authority" "vault_private_ca" {
  type                          = "ROOT"
  key_storage_security_standard = "FIPS_140_2_LEVEL_3_OR_HIGHER"
  usage_mode                    = "GENERAL_PURPOSE"

  certificate_authority_configuration {
    key_algorithm     = "RSA_2048"
    signing_algorithm = "SHA256WITHRSA"

    subject {
      organization = "vault-private-ca"
    }
  }

  revocation_configuration {
    crl_configuration {
      enabled = false
    }
    ocsp_configuration {
      enabled = false
    }
  }
}

locals {
  aws_privateca_issuer_assocations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.aws_privateca_issuer
    if v.enable_pod_identity_associations && v.pod_identity_associations.aws_privateca_issuer.enabled
  }
}

resource "aws_iam_role" "cert_manager_private_ca" {
  count = length(local.aws_privateca_issuer_assocations) > 0 ? 1 : 0
  name  = "CertManagerPrivateCARole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "TrustPolicyForEKSClusters"
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

resource "aws_iam_role_policy_attachment" "cert_manager_private_ca" {
  count      = length(local.aws_privateca_issuer_assocations) > 0 ? 1 : 0
  role       = aws_iam_role.cert_manager_private_ca[0].name
  policy_arn = "arn:aws:iam::aws:policy/AWSPrivateCAConnectorForKubernetesPolicy"
}

resource "aws_eks_addon" "aws_privateca_connector_for_kubernetes" {
  for_each = local.aws_privateca_issuer_assocations

  cluster_name  = each.key
  addon_name    = "aws-privateca-connector-for-kubernetes"
  addon_version = each.value.addon_version

  tags = each.value.tags
}

resource "aws_eks_pod_identity_association" "aws_privateca_issuer" {
  for_each = local.aws_privateca_issuer_assocations

  cluster_name    = each.key
  namespace       = each.value.namespace
  service_account = each.value.service_account_name
  role_arn        = aws_iam_role.cert_manager_private_ca[0].arn
  tags            = each.value.tags

  depends_on = [aws_eks_addon.aws_privateca_connector_for_kubernetes]
}
