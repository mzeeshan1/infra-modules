
locals {
  cert_manager_assocations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.cert_manager
    if v.enable_pod_identity_associations && v.pod_identity_associations.cert_manager.enabled
  }
  cluster_autoscaler_assocations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.cluster_autoscaler
    if v.enable_pod_identity_associations && v.pod_identity_associations.cluster_autoscaler.enabled
  }
  external_dns_assocations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.external_dns
    if v.enable_pod_identity_associations && v.pod_identity_associations.external_dns.enabled
  }
  ack_rds_controller_assocations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.ack_rds_controller
    if v.enable_pod_identity_associations && v.pod_identity_associations.ack_rds_controller.enabled
  }
  efs_csi_driver_assocations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.efs_csi_driver
    if v.enable_pod_identity_associations && v.pod_identity_associations.efs_csi_driver.enabled
  }
  aws_lb_controller_associations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.aws_lb_controller
    if v.enable_pod_identity_associations && v.pod_identity_associations.aws_lb_controller.enabled
  }
  external_secrets_associations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.external_secrets
    if v.enable_pod_identity_associations && v.pod_identity_associations.aws_lb_controller.enabled
  }
  ebs_csi_controller_associations = {
    for k, v in var.clusters : module.eks[k].cluster_name => v.pod_identity_associations.ebs_csi_controller
    if v.enable_pod_identity_associations && v.pod_identity_associations.ebs_csi_controller.enabled
  }
  crossplane_provider_roles = merge({}, [
    for k, v in var.clusters : {
      for provider, cfg in v.pod_identity_associations.crossplane.providers : "${k}-${provider}" => {
        cluster_name           = module.eks[k].cluster_name
        provider               = provider
        namespace              = v.pod_identity_associations.crossplane.namespace
        tags                   = v.pod_identity_associations.crossplane.tags
        policy_statements      = cfg.policy_statements
        additional_policy_arns = cfg.additional_policy_arns
      }
    }
    if v.enable_pod_identity_associations && v.pod_identity_associations.crossplane.enabled
  ]...)
}

module "cert_manager_pod_identity" {
  source                        = "terraform-aws-modules/eks-pod-identity/aws"
  version                       = "1.4.1"
  count                         = length(local.cert_manager_assocations) > 0 ? 1 : 0
  name                          = "cert-manager"
  attach_cert_manager_policy    = true
  cert_manager_hosted_zone_arns = ["*"]
  association_defaults          = merge([for k, v in local.cert_manager_assocations : tomap({ "namespace" = v.namespace, "service_account" = v.service_account_name })]...)
  associations                  = { for k, v in local.cert_manager_assocations : k => { "cluster_name" = k } }
  tags                          = merge([for k, v in local.cert_manager_assocations : merge(tomap({ "eks_pod_identity_association" = "cert-manager" }), v.tags)]...)
}

module "cluster_autoscaler_pod_identity" {
  source                           = "terraform-aws-modules/eks-pod-identity/aws"
  version                          = "1.4.1"
  count                            = length(local.cluster_autoscaler_assocations) > 0 ? 1 : 0
  name                             = "cluster-autoscaler"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_names = [for k, v in local.cluster_autoscaler_assocations : k]
  association_defaults             = merge([for k, v in local.cluster_autoscaler_assocations : tomap({ "namespace" = v.namespace, "service_account" = v.service_account_name })]...)
  associations                     = { for k, v in local.cluster_autoscaler_assocations : k => { "cluster_name" = k } }
  tags                             = merge([for k, v in local.cluster_autoscaler_assocations : merge(tomap({ "eks_pod_identity_association" = "cluster-autoscaler" }), v.tags)]...)
}

module "external_dns_pod_identity" {
  source                        = "terraform-aws-modules/eks-pod-identity/aws"
  version                       = "1.4.1"
  count                         = length(local.external_dns_assocations) > 0 ? 1 : 0
  name                          = "external-dns"
  attach_external_dns_policy    = true
  external_dns_hosted_zone_arns = ["*"]
  association_defaults          = merge([for k, v in local.external_dns_assocations : tomap({ "namespace" = v.namespace, "service_account" = v.service_account_name })]...)
  associations                  = { for k, v in local.external_dns_assocations : k => { "cluster_name" = k } }
  tags                          = merge([for k, v in local.external_dns_assocations : merge(tomap({ "eks_pod_identity_association" = "external-dns" }), v.tags)]...)
}

module "ack_pod_identity" {
  source  = "terraform-aws-modules/eks-pod-identity/aws"
  version = "1.4.1"
  count   = length(local.ack_rds_controller_assocations) > 0 ? 1 : 0
  name    = "ack-rds-controller"
  additional_policy_arns = {
    ACK_RDS_Controller_Policy = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  }
  association_defaults = merge([for k, v in local.ack_rds_controller_assocations : tomap({ "namespace" = v.namespace, "service_account" = v.service_account_name })]...)
  associations         = { for k, v in local.ack_rds_controller_assocations : k => { "cluster_name" = k } }
  tags                 = merge([for k, v in local.ack_rds_controller_assocations : merge(tomap({ "eks_pod_identity_association" = "ack-rds-controller" }), v.tags)]...)
}

module "efs_csi_driver_pod_identity" {
  source                    = "terraform-aws-modules/eks-pod-identity/aws"
  version                   = "1.4.1"
  count                     = length(local.efs_csi_driver_assocations) > 0 ? 1 : 0
  name                      = "efs-csi-driver"
  attach_aws_efs_csi_policy = true
  association_defaults      = merge([for k, v in local.efs_csi_driver_assocations : tomap({ "namespace" = v.namespace, "service_account" = v.service_account_name })]...)
  associations              = { for k, v in local.efs_csi_driver_assocations : k => { "cluster_name" = k } }
  tags                      = merge([for k, v in local.efs_csi_driver_assocations : merge(tomap({ "eks_pod_identity_association" = "efs-csi-driver" }), v.tags)]...)
}

module "aws_lb_controller_pod_identity" {
  source                          = "terraform-aws-modules/eks-pod-identity/aws"
  version                         = "1.12.1"
  count                           = length(local.aws_lb_controller_associations) > 0 ? 1 : 0
  name                            = "aws-lb-controller"
  attach_aws_lb_controller_policy = true
  association_defaults            = merge([for k, v in local.aws_lb_controller_associations : tomap({ "namespace" = v.namespace, "service_account" = v.service_account_name })]...)
  associations                    = { for k, v in local.aws_lb_controller_associations : k => { "cluster_name" = k } }
  tags                            = merge([for k, v in local.aws_lb_controller_associations : merge(tomap({ "eks_pod_identity_association" = "aws-lb-controller" }), v.tags)]...)
}

module "external_secrets_pod_identity" {
  source                         = "terraform-aws-modules/eks-pod-identity/aws"
  version                        = "1.12.1"
  count                          = length(local.aws_lb_controller_associations) > 0 ? 1 : 0
  name                           = "external-secrets"
  attach_external_secrets_policy = true
  additional_policy_arns = {
    ecr = aws_iam_policy.external_secrets_ecr.arn
  }
  association_defaults = merge([for k, v in local.external_secrets_associations : tomap({ "namespace" = v.namespace, "service_account" = v.service_account_name })]...)
  associations         = { for k, v in local.external_secrets_associations : k => { "cluster_name" = k } }
  tags                 = merge([for k, v in local.external_secrets_associations : merge(tomap({ "eks_pod_identity_association" = "external-secrets" }), v.tags)]...)
}

module "ebs_csi_controller_identity" {
  source                    = "terraform-aws-modules/eks-pod-identity/aws"
  version                   = "1.12.1"
  count                     = length(local.ebs_csi_controller_associations) > 0 ? 1 : 0
  name                      = "ebs-csi-controller"
  attach_aws_ebs_csi_policy = true
  association_defaults      = merge([for k, v in local.ebs_csi_controller_associations : tomap({ "namespace" = v.namespace, "service_account" = v.service_account_name })]...)
  associations              = { for k, v in local.ebs_csi_controller_associations : k => { "cluster_name" = k } }
  tags                      = merge([for k, v in local.ebs_csi_controller_associations : merge(tomap({ "eks_pod_identity_association" = "ebs-csi-controller" }), v.tags)]...)
}

module "crossplane_pod_identity" {
  source   = "terraform-aws-modules/eks-pod-identity/aws"
  version  = "1.12.1"
  for_each = local.crossplane_provider_roles

  name = "crossplane-${each.key}"

  attach_custom_policy   = length(each.value.policy_statements) > 0
  policy_statements      = each.value.policy_statements
  additional_policy_arns = each.value.additional_policy_arns

  associations = {
    (each.value.cluster_name) = {
      cluster_name    = each.value.cluster_name
      namespace       = each.value.namespace
      service_account = "provider-aws-${each.value.provider}"
    }
  }

  tags = merge(
    { eks_pod_identity_association = "crossplane-provider-${each.value.provider}" },
    each.value.tags
  )
}
resource "aws_iam_policy" "external_secrets_ecr" {
  name = "external-secrets-ecr"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*" # ECR GetAuthorizationToken can only be * 
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:ListImages"
        ]
        Resource = "arn:aws:ecr:eu-central-1:261175718795:repository/*"
      }
    ]
  })
}


