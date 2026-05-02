################################################################################
# Security group
################################################################################

module "sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.2.0"

  for_each = var.sg

  name                     = each.key
  description              = each.value.description
  vpc_id                   = each.value.vpc_id
  ingress_cidr_blocks      = each.value.ingress_cidr_blocks
  ingress_with_cidr_blocks = each.value.ingress_with_cidr_blocks
  use_name_prefix          = each.value.use_name_prefix
  tags                     = { Terraform = "true" }
}
