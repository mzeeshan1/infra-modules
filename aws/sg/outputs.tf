output "security_group_ids" {
  description = "List of the VoIP security group IDs"
  value       = [for name in keys(var.sg) : module.sg[name].security_group_id]
}
