################################################################################
# Transit Gateway
################################################################################

module "tgw" {
  source          = "terraform-aws-modules/transit-gateway/aws"
  version         = "~> 2.11.0"
  for_each        = var.tgw
  name            = each.key
  share_tgw       = each.value.share_tgw
  vpc_attachments = each.value.vpc_attachments
  tags            = merge(each.value.tags, { Terraform = "true" })
}
