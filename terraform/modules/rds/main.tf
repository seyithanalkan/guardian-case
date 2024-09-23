resource "aws_secretsmanager_secret" "rds_credentials" {
  name        = "${var.environment}-${var.project}-rds-creds"
  description = "Credentials for the RDS instance"

  tags = {
    Name        = "${var.environment}-${var.project}-rds-creds"
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}

resource "random_password" "rds_password" {
  length  = 16
  special = var.environment == "prod" ? true : false
}

resource "aws_secretsmanager_secret_version" "rds_credentials_version" {
  secret_id     = aws_secretsmanager_secret.rds_credentials.id
  secret_string = jsonencode({
    db_username = var.rds_admin_username
    db_password = random_password.rds_password.result
    db_name     = var.rds_db_name
  })

  
}

resource "aws_db_instance" "this" {
  allocated_storage      = var.rds_allocated_storage
  engine                 = "postgres"
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance_class
  identifier             = var.rds_instance_identifier
  db_name                = var.rds_db_name
  username               = var.rds_admin_username
  password               = jsondecode(aws_secretsmanager_secret_version.rds_credentials_version.secret_string)["db_password"]
  port                   = 5432
  multi_az               = false
  storage_type           = "gp3"
  backup_retention_period = var.rds_backup_retention_period
  max_allocated_storage  = var.rds_max_allocated_storage

  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name

  snapshot_identifier    = var.snapshot_identifier != "" ? var.snapshot_identifier : null
  apply_immediately      = true
  skip_final_snapshot    = true
  publicly_accessible    = false

  monitoring_interval     = 60  
  monitoring_role_arn     = aws_iam_role.enhanced_monitoring_role.arn
  performance_insights_enabled = var.performance_insights_enabled

  lifecycle {
    ignore_changes = [
      db_name,
      username,
      snapshot_identifier
    ]
  }

  tags = {
    Name        = "${var.project}-${var.environment}-rds-instance"
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "${var.project}-${var.environment}-rds-subnet-group"
  subnet_ids = var.data_subnet_ids

  tags = {
    Name        = "${var.project}-${var.environment}-rds-subnet-group"
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}

resource "aws_security_group" "rds_sg" {
  name        = var.rds_security_group_name
  description = "RDS Security Group"
  vpc_id      = var.vpc_id

  tags = {
    Name        = var.rds_security_group_name
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}



resource "aws_iam_role" "enhanced_monitoring_role" {
  name               = "${var.project}-${var.environment}-rds-monitoring-role"
  assume_role_policy = data.aws_iam_policy_document.enhanced_monitoring.json

  tags = {
    Name        = "${var.project}-${var.environment}-rds-monitoring-role"
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
}

data "aws_iam_policy_document" "enhanced_monitoring" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "enhanced_monitoring_policy" {
  role       = aws_iam_role.enhanced_monitoring_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}


resource "aws_vpc_security_group_ingress_rule" "rds_sg_ingress_rule" {
  for_each = { for idx, sg in var.rds_sg_ingress_security_groups : idx => sg }

  security_group_id        = aws_security_group.rds_sg.id
  from_port                = 5432
  to_port                  = 5432
  ip_protocol              = "tcp"
  referenced_security_group_id = each.value.security_group_id
  description              = each.value.description  

  lifecycle {
    ignore_changes = [
      description
    ]
  }
}