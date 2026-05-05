variable "tgw" {
  description = "Transit gateway configuration"
  type = map(object({
    enable_auto_accept_shared_attachments = optional(bool, true)
    share_tgw                             = optional(bool, false)
    vpc_attachments = map(object({
      vpc_id                                          = string
      subnet_ids                                      = list(string)
      dns_support                                     = optional(bool, true)
      ipv6_support                                    = optional(bool, false)
      transit_gateway_default_route_table_association = optional(bool, false)
      transit_gateway_default_route_table_propagation = optional(bool, false)
      tgw_routes = optional(list(object({
        destination_cidr_block = string
        blackhole              = optional(bool)
      })))
    }))
    tags = optional(map(string), {})
  }))
  default = {}
}
