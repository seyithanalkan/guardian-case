resource "aws_security_group" "this" {
  name        = var.sg_name
  description = "Security group for ${var.sg_name}"
  vpc_id      = var.vpc_id

  tags = {
    Name        = var.sg_name
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}


resource "aws_security_group_rule" "ingress" {
  for_each = { for idx, rule in var.ingress_rules : idx => rule }

  type              = "ingress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  security_group_id = aws_security_group.this.id
  description       = each.value.description

  cidr_blocks = length(each.value.cidr_blocks) > 0 ? each.value.cidr_blocks : null

  source_security_group_id = each.value.source_security_group_id != "" ? each.value.source_security_group_id : null


  lifecycle {
    ignore_changes = [
      
    ]
  }
}

resource "aws_security_group_rule" "egress" {
  for_each = { for idx, rule in var.egress_rules : idx => rule }

  type              = "egress"
  from_port         = each.value.from_port
  to_port           = each.value.to_port
  protocol          = each.value.protocol
  cidr_blocks       = each.value.cidr_blocks
  security_group_id = aws_security_group.this.id
  lifecycle {
    ignore_changes = [
      cidr_blocks,
      from_port,
      to_port,
      protocol,
      security_group_id,
    ]
  }  
}