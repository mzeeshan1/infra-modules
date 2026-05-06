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
}
