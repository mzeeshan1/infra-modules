variable "sg" {
  description = "Common security group configuration"
  type = map(object({
    name                = optional(string)
    description         = optional(string)
    vpc_id              = optional(string)
    ingress_cidr_blocks = optional(list(string), [])
    # Using map(any) instead of object is required
    # due to the implementation of ingress_with_cidr_blocks and cidr_blocks parameter in particular
    # in the terraform-aws-modules/security-group/aws module
    ingress_with_cidr_blocks = optional(list(map(any)), [])
    use_name_prefix          = optional(bool, false)
  }))
  default = {}
}
