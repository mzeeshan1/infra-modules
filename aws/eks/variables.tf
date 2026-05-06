variable "clusters" {
  type = map(object({
    cluster_version                        = optional(string, "1.35")
    endpoint_private_access                = optional(bool, true)
    endpoint_public_access                 = optional(bool, false)
    cluster_enabled_log_types              = optional(list(string), [])
    cloudwatch_log_group_class             = optional(string, "INFREQUENT_ACCESS")
    cloudwatch_log_group_retention_in_days = optional(number, 30)
    tags                                   = optional(map(string), {})
    create_cluster_in_existing_vpc         = optional(bool, false)
    vpc_id                                 = optional(string)
    subnet_ids                             = optional(list(string))
    vpc = optional(object({
      cidr                          = optional(string, "10.0.0.0/16")
      azs                           = optional(list(string), ["eu-central-1a", "eu-central-1b", "eu-central-1c"])
      public_subnets                = optional(list(string), ["10.0.0.0/22", "10.0.4.0/22", "10.0.8.0/22"])
      public_subnet_tags            = optional(map(string))
      private_subnets               = optional(list(string), [])
      private_subnet_tags           = optional(map(string), {})
      public_subnet_tags_per_az     = optional(map(map(string)), {})
      map_public_ip_on_launch       = optional(bool, true)
      manage_default_network_acl    = optional(bool, true)
      manage_default_route_table    = optional(bool, true)
      manage_default_security_group = optional(bool, true)
      tags                          = optional(map(string), {})
    }), {})
    authentication_mode = optional(string, "API")
    cluster_addons = optional(map(object({
      addon_version               = string
      resolve_conflicts_on_update = optional(string, "OVERWRITE")
      resolve_conflicts_on_create = optional(string, "OVERWRITE")
      before_compute              = optional(bool, false)
      configuration_values        = optional(string, null)
      })), {
      coredns = {
        addon_version = "v1.14.2-eksbuild.4"
      },
      eks-pod-identity-agent = {
        addon_version = "v1.3.10-eksbuild.3"
      },
      kube-proxy = {
        addon_version = "v1.35.3-eksbuild.5"
      },
      # aws-ebs-csi-driver = {
      #   addon_version = "v1.59.0-eksbuild.1"
      # }
      aws-efs-csi-driver = {
        addon_version = "v3.0.1-eksbuild.1"
      }
      vpc-cni = {
        addon_version        = "v1.21.1-eksbuild.8"
        before_compute       = false
        configuration_values = "{\"env\": { \"ENABLE_PREFIX_DELEGATION\": \"true\"}}"
      }
    })
    cluster_tags = optional(map(string))
    node_security_group_additional_rules = optional(map(object({
      description                   = optional(string)
      protocol                      = string
      from_port                     = number
      to_port                       = number
      type                          = string
      source_cluster_security_group = optional(bool, false)
      self                          = optional(bool)
      cidr_blocks                   = optional(list(string))
    })), {})
    cluster_security_group_additional_rules = optional(map(object({
      description                   = optional(string)
      protocol                      = string
      from_port                     = number
      to_port                       = number
      type                          = string
      source_cluster_security_group = optional(bool, false)
      self                          = optional(bool)
      cidr_blocks                   = optional(list(string))
    })), {})
    enable_pod_identity_associations = optional(bool, true)
    pod_identity_associations = optional(object({
      cert_manager = optional(object({
        enabled              = optional(bool, true)
        namespace            = optional(string, "cert-manager")
        service_account_name = optional(string, "cert-manager")
        tags                 = optional(map(string), {})
      }), {})
      cluster_autoscaler = optional(object({
        enabled              = optional(bool, true)
        namespace            = optional(string, "kube-system")
        service_account_name = optional(string, "autoscaler-aws-cluster-autoscaler")
        tags                 = optional(map(string), {})
      }), {})
      external_dns = optional(object({
        enabled              = optional(bool, true)
        namespace            = optional(string, "kube-system")
        service_account_name = optional(string, "external-dns")
        tags                 = optional(map(string), {})
      }), {})
      ack_rds_controller = optional(object({
        enabled              = optional(bool, true)
        namespace            = optional(string, "ack-system")
        service_account_name = optional(string, "ack-rds-controller")
        tags                 = optional(map(string), {})
      }), {})
      efs_csi_driver = optional(object({
        enabled              = optional(bool, true)
        namespace            = optional(string, "kube-system")
        service_account_name = optional(string, "efs-csi-controller-sa")
        tags                 = optional(map(string), {})
      }), {})
      }), {
      cert_manager       = {}
      cluster_autoscaler = {}
      external_dns       = {}
      ack_rds_controller = {}
    })
    karpenter = optional(object({
      enabled              = optional(bool, false)
      service_account_name = optional(string, "karpenter")
      namespace            = optional(string, "kube-system")
      tags                 = optional(map(string), {})
    }), {})
    node_groups = map(object({
      ami_id                       = optional(string, "ami-0d8f744c48bb12f65")
      instance_types               = optional(list(string), ["t3a.large"])
      ami_type                     = optional(string, "CUSTOM")
      capacity_type                = optional(string, "SPOT")
      desired_size                 = optional(number, 2)
      max_size                     = optional(number, 2)
      min_size                     = optional(number, 1)
      labels                       = optional(map(string), {})
      taints                       = optional(any, {})
      tags                         = optional(map(string), {})
      enable_bootstrap_user_data   = optional(bool, true)
      attach_voip_security_group   = optional(bool, true)
      vpc_security_group_ids       = optional(list(string), [])
      iam_role_additional_policies = optional(map(string), {})
      block_device_mappings = optional(map(object({
        device_name = optional(string, "/dev/sda1")
        ebs = optional(object({
          volume_type           = optional(string, "gp3")
          volume_size           = optional(number, 100)
          iops                  = optional(number, 3000)
          throughput            = optional(number, 125)
          encrypted             = optional(bool, true)
          delete_on_termination = optional(bool, true)
          }
        ), {})
        })), {
        xvda = {}
      })
    }))
    access_entries = optional(map(object({
      principal_arn = string
      policy_associations = map(object({
        policy_arn = string
        access_scope = object({
          type       = string
          namespaces = optional(list(string))
        })
      }))
    })), {})
  }))
  validation {
    condition = alltrue([
      for k, v in var.clusters :
      (!v.create_cluster_in_existing_vpc) || (v.subnet_ids != null && v.vpc_id != "")
    ])
    error_message = "If a cluster is being created in an existing VPC, then VPC ID and subnet IDs must be set."
  }
  description = "Configuration for each EKS cluster"
  default     = {}
}
