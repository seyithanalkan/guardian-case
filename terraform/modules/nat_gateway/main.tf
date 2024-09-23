resource "aws_nat_gateway" "this" {
  allocation_id = var.allocation_id
  subnet_id     = var.subnet_id

  tags = {
    Name        = format("%s-%s-natgw", var.project, var.environment)
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}
