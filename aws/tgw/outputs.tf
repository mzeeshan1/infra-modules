output "tgw_id" {
  description = "Transit Gateway IDs keyed by name"
  value = {
    for k, v in module.tgw : k => v.ec2_transit_gateway_id
  }
}

output "tgw_arn" {
  description = "Transit Gateway ARNs keyed by name"
  value = {
    for k, v in module.tgw : k => v.ec2_transit_gateway_arn
  }
}

output "tgw_route_table_id" {
  description = "Transit Gateway default route table IDs keyed by name"
  value = {
    for k, v in module.tgw : k => v.ec2_transit_gateway_association_default_route_table_id
  }
}

output "tgw_vpc_attachment_ids" {
  description = "Transit Gateway VPC attachment IDs keyed by tgw name, then vpc name"
  value = {
    for k, v in module.tgw : k => {
      for ak, av in v.ec2_transit_gateway_vpc_attachment : ak => av.id
    }
  }
}
