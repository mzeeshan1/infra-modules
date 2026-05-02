locals {
  karpenter_enabled_clusters = { for k, v in var.clusters : module.eks[k].cluster_name => v
    if v.karpenter.enabled
  }
}

module "karpenter" {
  source                          = "terraform-aws-modules/eks/aws//modules/karpenter"
  version                         = "20.24.0"
  for_each                        = local.karpenter_enabled_clusters
  cluster_name                    = each.key
  create_pod_identity_association = true
  enable_pod_identity             = true
  service_account                 = each.value.karpenter.service_account_name
  namespace                       = each.value.karpenter.namespace
  create_access_entry             = true
  tags                            = each.value.karpenter.tags
}
