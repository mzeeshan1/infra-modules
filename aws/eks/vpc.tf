################################################################################
# VPC
################################################################################

locals {
  vpc = {
    for cluster_name, cluster_data in var.clusters : "${cluster_name}" => merge(
      cluster_data.vpc, { tags = merge(cluster_data.vpc.tags, cluster_data.tags, { "cluster_name" = cluster_name }) }
    )
    if !cluster_data.create_cluster_in_existing_vpc
  }
}

module "vpc" {
  source = "/Users/muhammadzeeshan/Documents/Babelforce/Babelforce-Repos/terraform-modules/aws/vpc"
  vpc    = local.vpc
}
