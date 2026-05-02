################################################################################
# EKS
################################################################################

data "aws_caller_identity" "current" {}

module "eks" {
  source                                  = "terraform-aws-modules/eks/aws"
  version                                 = "20.24.0"
  for_each                                = var.clusters
  cluster_name                            = each.key
  cluster_version                         = each.value.cluster_version
  cluster_endpoint_private_access         = each.value.endpoint_private_access
  cluster_endpoint_public_access          = each.value.endpoint_public_access
  cluster_enabled_log_types               = each.value.cluster_enabled_log_types
  cloudwatch_log_group_class              = each.value.cloudwatch_log_group_class
  cloudwatch_log_group_retention_in_days  = each.value.cloudwatch_log_group_retention_in_days
  vpc_id                                  = each.value.create_cluster_in_existing_vpc ? each.value.vpc_id : local.clusters_vpc_ids[each.key]
  subnet_ids                              = each.value.create_cluster_in_existing_vpc ? each.value.subnet_ids : local.clusters_public_subnets[each.key]
  authentication_mode                     = each.value.authentication_mode
  node_security_group_additional_rules    = merge(each.value.node_security_group_additional_rules, local.default_node_security_group_rules)
  cluster_security_group_additional_rules = each.value.cluster_security_group_additional_rules
  cluster_addons                          = each.value.cluster_addons
  eks_managed_node_groups                 = local.eks_managed_node_groups[each.key]
  access_entries                          = merge(each.value.access_entries, local.default_access_entries)
  tags                                    = merge(each.value.tags, { "cluster_name" = each.key })
}

module "key_pair" {
  source             = "terraform-aws-modules/key-pair/aws"
  version            = "2.0.3"
  for_each           = local.public_keys
  key_name_prefix    = each.key
  public_key         = file(each.value)
  create_private_key = false
  tags               = merge({ "cluster_name" = each.key })
}
