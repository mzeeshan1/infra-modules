################################################################################
# VPC
################################################################################

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.13.0"

  for_each = var.vpc

  name                      = each.key
  cidr                      = each.value.cidr
  azs                       = each.value.azs
  public_subnets            = each.value.public_subnets
  public_subnet_tags        = each.value.public_subnet_tags
  private_subnets           = each.value.private_subnets
  private_subnet_tags       = each.value.private_subnet_tags
  public_subnet_tags_per_az = each.value.public_subnet_tags_per_az
  map_public_ip_on_launch   = each.value.map_public_ip_on_launch

  manage_default_vpc                   = each.value.manage_default_vpc
  manage_default_network_acl           = each.value.manage_default_network_acl
  manage_default_security_group        = each.value.manage_default_security_group
  manage_default_route_table           = each.value.manage_default_route_table
  default_route_table_propagating_vgws = each.value.default_route_table_propagating_vgws

  tags = merge(each.value.tags, { Terraform = "true" })
}
