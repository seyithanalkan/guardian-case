output "role_name" {
  value = aws_iam_role.this.name
}



output "role_arn" {
  value = aws_iam_role.this.arn
}

output "instance_profile_name" {
  value = var.create_instance_profile ? aws_iam_instance_profile.this[0].name : ""
}

output "instance_profile_arn" {
  value = var.create_instance_profile ? aws_iam_instance_profile.this[0].arn : ""
}

