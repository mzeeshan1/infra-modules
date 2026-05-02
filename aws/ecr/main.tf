resource "aws_ecr_repository" "repos" {
  for_each = var.repositories

  name                 = each.value.name
  image_tag_mutability = each.value.image_tag_mutability

  image_scanning_configuration {
    scan_on_push = each.value.scan_on_push
  }
  encryption_configuration {
    encryption_type = each.value.encryption_type
  }
  # dynamic "image_tag_mutability_exclusion_filter" {
  #   for_each = each.value.image_tag_mutability_exclusion_filters
  #   content {
  #     filter      = image_tag_mutability_exclusion_filter.value.filter
  #     filter_type = image_tag_mutability_exclusion_filter.value.filter_type
  #   }
  # }
}
