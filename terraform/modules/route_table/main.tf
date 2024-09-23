resource "aws_route_table" "this" {
  vpc_id = var.vpc_id

  dynamic "route" {
    for_each = var.route_type == "data" ? [] : [1]  
    content {
      cidr_block = "0.0.0.0/0"
      
      gateway_id     = var.route_type == "public" ? var.gateway_id : null
      nat_gateway_id = var.route_type == "private" ? var.nat_gateway_id : null
    }
  }

  tags = {
    Name        = format("%s-%s-%s-rtb", var.project, var.environment, var.route_type)
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}

resource "aws_route_table_association" "this" {
  for_each = { for idx, subnet_id in var.subnet_ids : idx => subnet_id }

  subnet_id      = each.value
  route_table_id = aws_route_table.this.id
}
