resource "aws_ecr_repository" "this" {
  name = "${var.app_name}"

  image_tag_mutability = "MUTABLE"
  image_scanning_configuration {
    scan_on_push = true
  }
 
  tags = {
    Name        = "${var.app_name}-${var.project}-${var.environment}-ecr"
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
 
}
