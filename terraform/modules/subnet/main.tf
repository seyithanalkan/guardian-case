resource "aws_subnet" "this" {
  for_each = { for index, az in tolist(var.availability_zones) : az => index + 1 }

  vpc_id            = var.vpc_id
  
  cidr_block = cidrsubnet(
    var.vpc_cidr,
    8,
    var.subnet_offset + each.value
  )
  
  availability_zone = each.key

  tags = {
    Name        = format("%s-%s-%s-subnet-%s", var.project, var.environment, var.subnet_type, each.key)
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }

  map_public_ip_on_launch = var.subnet_type == "public" ? true : false
}
