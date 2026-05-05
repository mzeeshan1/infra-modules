output "vpc_id" {
  description = "Map of VPC names and VPC IDs"
  value       = { for name in keys(var.vpc) : name => module.vpc[name].vpc_id }
}

output "vpc_cidr_block" {
  description = "Map of VPC names and VPC CIDR blocks"
  value       = { for name in keys(var.vpc) : name => module.vpc[name].vpc_cidr_block }
}

output "default_vpc_id" {
  description = "Map of VPC names and default VPC IDs"
  value       = { for name in keys(var.vpc) : name => module.vpc[name].default_vpc_id }
}

output "default_vpc_cidr_block" {
  description = "Map of VPC names and default CIDR block"
  value       = { for name in keys(var.vpc) : name => module.vpc[name].default_vpc_cidr_block }
}

output "public_subnets" {
  description = "Map of VPC names and VPC public subnets"
  value       = { for name in keys(var.vpc) : name => module.vpc[name].public_subnets }
}

output "private_subnets" {
  description = "Map of VPC names and VPC private subnets"
  value       = { for name in keys(var.vpc) : name => module.vpc[name].private_subnets }
}

output "public_route_table_ids" {
  description = "Map of VPC names and list of IDs of public route tables"
  value       = { for name in keys(var.vpc) : name => module.vpc[name].public_route_table_ids }
}

output "private_route_table_ids" {
  description = "Map of VPC names and list of IDs of private route tables"
  value       = { for name in keys(var.vpc) : name => module.vpc[name].private_route_table_ids }
}
