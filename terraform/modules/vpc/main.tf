resource "aws_vpc" "this" {
  cidr_block = var.vpc_cidr

  tags = {
    Name        = format("%s-%s-vpc", var.project, var.environment)
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }

  enable_dns_hostnames = true
}
