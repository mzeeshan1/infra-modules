locals {
  clusters_vpc_ids = { for cluster_name, cluster_data in var.clusters : cluster_name => module.vpc.vpc_id["${cluster_name}"]
    if !cluster_data.create_cluster_in_existing_vpc
  }
  clusters_public_subnets = { for cluster_name, cluster_data in var.clusters : cluster_name => module.vpc.public_subnets["${cluster_name}"]
    if !cluster_data.create_cluster_in_existing_vpc
  }
  public_keys = {
    for k, _ in var.clusters :
    k => (
      fileexists("${path.root}/keys/${k}.pub") ?
      "${path.root}/keys/${k}" :
      fileexists("${path.root}/keys/common.pub") ?
      "${path.root}/keys/common.pub" : null
    )
    if fileexists("${path.root}/keys/${k}.pub") || fileexists("${path.root}/keys/common.pub")
  }
  eks_managed_node_groups = { for cluster_key, cluster_value in var.clusters : cluster_key =>
    { for key, ng in cluster_value.node_groups : key => merge(ng, {
      # Include cluster and node group names to prefix
      name                   = "${cluster_key}-${key}"
      iam_role_name          = "${cluster_key}-${key}"
      launch_template_name   = "${cluster_key}-${key}"
      subnet_ids             = cluster_value.create_cluster_in_existing_vpc ? cluster_value.subnet_ids : local.clusters_public_subnets[cluster_key]
      labels                 = merge({ "cluster_name" = cluster_key }, ng.labels)
      taints                 = ng.taints
      key_name               = try(module.key_pair[cluster_key].key_pair_name, "")
      vpc_security_group_ids = []
      # This default can't be defined in variables because policy ARN is always a dynamic value
      # iam_role_additional_policies = { ECRReadOnly = module.iam_policy.arn["ECRReadOnly"] }
      pre_bootstrap_user_data = templatefile("${path.module}/pre_bootstrap_user_data.tftpl",
        {
          # Extract numeric version since max-pods-calculator.sh script doesn't support full naming convention
          # Example: v1.18.1-eksbuild.1 -> 1.18.1
          vpc_cni_version = regex("^v([0-9]+\\.[0-9]+\\.[0-9]+)-", cluster_value.cluster_addons.vpc-cni.addon_version)[0]
          prefix_delegation_enabled = (
            lookup(
              cluster_value.cluster_addons.vpc-cni.configuration_values != null ?
              jsondecode(cluster_value.cluster_addons.vpc-cni.configuration_values).env : {},
              "ENABLE_PREFIX_DELEGATION", "false"
            ) == "true"
          )
        }
      )
      tags = merge(cluster_value.tags, { "name" = key, "cluster_name" = cluster_key }, ng.tags)
  }) } }

  # This default can't be defined in variables because `principal_arn` is always a dynamic value
  default_access_entries = {
    admin = {
      principal_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/zeeshan"
      policy_associations = {
        admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  default_node_security_group_rules = {
    node_to_node_ingress_http = {
      description = "Allow node-to-node on 80 for ingress"
      protocol    = "tcp"
      to_port     = 80
      from_port   = 80
      type        = "ingress"
      self        = true
    }
    node_to_node_ingress_https = {
      description = "Allow node-to-node on 443 for ingress"
      protocol    = "tcp"
      to_port     = 443
      from_port   = 443
      type        = "ingress"
      self        = true
    }
    http_to_node_from_everywhere = {
      description = "Allow http on 8080"
      protocol    = "tcp"
      to_port     = 8080
      from_port   = 8080
      type        = "ingress"
      cidr        = ["0.0.0.0/0"]

    }
  }
}
