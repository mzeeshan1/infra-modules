
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
  association_defaults           = merge([for k, v in local.external_secrets_associations : tomap({ "namespace" = v.namespace, "service_account" = v.service_account_name })]...)
  associations                   = { for k, v in local.external_secrets_associations : k => { "cluster_name" = k } }
  tags                           = merge([for k, v in local.external_secrets_associations : merge(tomap({ "eks_pod_identity_association" = "external-secrets" }), v.tags)]...)
}
