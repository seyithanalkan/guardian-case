output "subnet_ids" {
  description = "The IDs of the created subnets"
  value       = { for k, v in aws_subnet.this : k => v.id }
}

output "subnet_cidrs" {
  description = "The CIDR blocks of the created subnets"
  value       = { for k, v in aws_subnet.this : k => v.cidr_block }
}
