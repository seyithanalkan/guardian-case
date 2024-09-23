module "rds_postgres" {
  source                  = "../modules/rds"
  region                  = var.region
  environment             = var.environment
  project                 = var.project
  cost_center             = var.rds_cost_center
  vpc_id                  = module.vpc.vpc_id
  rds_instance_identifier = format("%s-%s-db-instance", var.project, var.environment)
  rds_instance_class      = var.rds_instance_class
  rds_allocated_storage   = var.rds_allocated_storage
  rds_engine_version      = var.rds_engine_version
  rds_admin_username      = var.rds_admin_username
  rds_db_name             = format("%s%sdb", var.project, var.environment)
  rds_security_group_name = format("%s-%s-rds-sg", var.project, var.environment)

  rds_sg_ingress_security_groups = [
    {
      security_group_id = module.eks_cluster.eks_node_group_security_group
      description       = "Node Group Access"
    }
  ]

  data_subnet_ids              = values(module.data_subnets.subnet_ids)
  rds_backup_retention_period  = var.rds_backup_retention_period
  rds_storage_autoscale        = var.rds_storage_autoscale
  rds_max_allocated_storage    = var.rds_max_allocated_storage
  performance_insights_enabled = var.performance_insights_enabled
}