output "rds_endpoint" {
  description = "The connection endpoint for the RDS instance"
  value       = aws_db_instance.this.endpoint
}

output "rds_master_username" {
  description = "The master username for the RDS instance"
  value       = aws_db_instance.this.username
}

output "rds_security_group_id" {
  description = "The security group ID for the RDS instance"
  value       = aws_security_group.rds_sg.id
}

output "rds_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = aws_db_instance.this.arn
}
