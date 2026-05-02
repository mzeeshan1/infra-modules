# ################################################################################
# ## Security Groups ###
# ################################################################################

output "eks_workers_security_group_id" {
  description = "ID of the workers security group"
  value       = { for name in keys(var.clusters) : name => module.eks[name].node_security_group_id }
}

output "eks_workers_security_group_arn" {
  description = "Amazon Resource Name (ARN) of the workers security group"
  value       = { for name in keys(var.clusters) : name => module.eks[name].node_security_group_arn }
}

output "eks_cluster_security_group_id" {
  description = "ID of the cluster security group"
  value       = { for name in keys(var.clusters) : name => module.eks[name].cluster_security_group_id }
}

output "cluster_primary_security_group_id" {
  description = "Cluster security group that was created by Amazon EKS for the cluster. Managed node groups use this security group for control-plane-to-data-plane communication. Referred to as 'Cluster security group' in the EKS console"
  value       = { for name in keys(var.clusters) : name => module.eks[name].cluster_primary_security_group_id }
}

################################################################################
# VPC
################################################################################

output "eks_cluster_vpc_id" {
  description = "Map of VPC names and VPC IDs"
  value       = module.vpc.vpc_id
}

output "eks_cluster_vpc_cidr_block" {
  description = "Map of VPC names and VPC CIDR blocks"
  value       = module.vpc.vpc_cidr_block
}

output "eks_cluster_public_subnets" {
  description = "Map of VPC names and VPC public subnets"
  value       = module.vpc.public_subnets
}

output "eks_cluster_private_subnets" {
  description = "Map of VPC names and VPC private subnets"
  value       = module.vpc.private_subnets
}

output "eks_cluster_public_route_table_ids" {
  description = "Map of VPC names and list of IDs of public route tables"
  value       = module.vpc.public_route_table_ids
}

output "eks_cluster_private_route_table_ids" {
  description = "Map of VPC names and list of IDs of private route tables"
  value       = module.vpc.private_route_table_ids
}

################################################################################
# IAM Role
################################################################################

output "cluster_iam_arn" {
  description = "Amazon Resource Name (ARN) of the cluster IAM role"
  value       = { for name in keys(var.clusters) : name => module.eks[name].cluster_iam_role_arn }
}

output "cluster_iam_role_name" {
  description = "IAM role name of the EKS cluster"
  value       = { for name in keys(var.clusters) : name => module.eks[name].cluster_iam_role_name }
}

################################################################################
# Cluster
################################################################################

output "cluster_arn" {
  description = "The Amazon Resource Name (ARN) of the cluster"
  value       = { for name in keys(var.clusters) : name => module.eks[name].cluster_arn }
}

output "cluster_endpoint" {
  description = "Endpoint for your Kubernetes API server"
  value       = { for name in keys(var.clusters) : name => module.eks[name].cluster_endpoint }
}

output "cluster_name" {
  description = "The name of the EKS cluster"
  value       = { for name in keys(var.clusters) : name => module.eks[name].cluster_name }
}

output "cluster_platform_version" {
  description = "Platform version for the cluster"
  value       = { for name in keys(var.clusters) : name => module.eks[name].cluster_platform_version }
}

output "cluster_status" {
  description = "Status of the EKS cluster. One of `CREATING`, `ACTIVE`, `DELETING`, `FAILED`"
  value       = { for name in keys(var.clusters) : name => module.eks[name].cluster_status }
}

# ################################################################################
# # Worker Groups
# ################################################################################

output "eks_managed_node_groups" {
  description = "Map of managed node groups in the EKS cluster"
  value       = { for name in keys(var.clusters) : name => module.eks[name].eks_managed_node_groups }
}

# ################################################################################
# # Pod Identity Assocations
# ################################################################################

output "cert_manager_pod_identity_iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.cert_manager_pod_identity[*].iam_role_arn
}

output "cert_manager_pod_identity_iam_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = module.cert_manager_pod_identity[*].iam_policy_arn
}

output "cert_manager_pod_identity_associations" {
  description = "Map of Pod Identity associations created"
  value       = module.cert_manager_pod_identity[*].associations
}

output "cluster_autoscaler_pod_identity_iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.cluster_autoscaler_pod_identity[*].iam_role_arn
}

output "cluster_autoscaler_pod_identity_iam_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = module.cluster_autoscaler_pod_identity[*].iam_policy_arn
}

output "cluster_autoscaler_pod_identity_associations" {
  description = "Map of Pod Identity associations created"
  value       = module.cluster_autoscaler_pod_identity[*].associations
}

output "external_dns_pod_identity_iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.external_dns_pod_identity[*].iam_role_arn
}

output "external_dns_pod_identity_iam_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = module.external_dns_pod_identity[*].iam_policy_arn
}

output "external_dns_pod_identity_associations" {
  description = "Map of Pod Identity associations created"
  value       = module.external_dns_pod_identity[*].associations
}

output "ack_rds_controller_pod_identity_iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.ack_pod_identity[*].iam_role_arn
}

output "ack_rds_controller_pod_identity_iam_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = module.ack_pod_identity[*].iam_policy_arn
}

output "ack_rds_controller_pod_identity_associations" {
  description = "Map of Pod Identity associations created"
  value       = module.ack_pod_identity[*].associations
}

output "efs_csi_driver_pod_identity_iam_role_arn" {
  description = "ARN of IAM role"
  value       = module.efs_csi_driver_pod_identity[*].iam_role_arn
}

output "efs_csi_driver_pod_identity_iam_policy_arn" {
  description = "The ARN assigned by AWS to this policy"
  value       = module.efs_csi_driver_pod_identity[*].iam_policy_arn
}

output "efs_csi_driver_pod_identity_associations" {
  description = "Map of Pod Identity associations created"
  value       = module.efs_csi_driver_pod_identity[*].associations
}
