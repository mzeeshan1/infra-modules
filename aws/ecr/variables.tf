variable "repositories" {
  description = "Map of ECR repositories to create"
  type = map(object({
    name                 = string
    image_tag_mutability = optional(string, "MUTABLE")
    scan_on_push         = optional(bool, true)
  }))
}
