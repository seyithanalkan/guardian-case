resource "aws_iam_role" "this" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = var.assume_role_service
      }
    }]
  })

  tags = {
    Name        = var.role_name
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_by  = var.created_by
  }
}

resource "aws_iam_role_policy_attachment" "this" {
  count      = length(var.policy_arns)
  role       = aws_iam_role.this.name
  policy_arn = var.policy_arns[count.index]
}

resource "aws_iam_instance_profile" "this" {
  count = var.create_instance_profile ? 1 : 0
  name  = "${var.role_name}-instance-profile"
  role  = aws_iam_role.this.name
}
