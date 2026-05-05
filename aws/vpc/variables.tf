variable "vpc" {
  description = "VPC configuration"
  type = map(object({
    cidr                                 = string
    azs                                  = list(string)
    public_subnets                       = optional(list(string), [])
    public_subnet_tags                   = optional(map(string))
    private_subnets                      = optional(list(string), [])
    private_subnet_tags                  = optional(map(string))
    public_subnet_tags_per_az            = optional(map(map(string)), {})
    map_public_ip_on_launch              = optional(bool, true)
    manage_default_vpc                   = optional(bool, false)
    manage_default_network_acl           = optional(bool, true)
    manage_default_security_group        = optional(bool, true)
    manage_default_route_table           = optional(bool, true)
    default_route_table_propagating_vgws = optional(list(string), [])
    tags                                 = optional(map(string), {})
  }))
  default = {}
}
