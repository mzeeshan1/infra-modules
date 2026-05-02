variable "repositories" {
  description = "Map of ECR repositories to create"
  type = map(object({
    name                 = string
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push         = optional(bool, true)
    encryption_type      = optional(string, "KMS")
    image_tag_mutability_exclusion_filters = optional(list(object({
      filter      = string
      filter_type = string
    })), [])
  }))
}
