variable "rds_instance_identifier" {
  description = "The identifier for the RDS instance"
  type        = string
}

variable "rds_instance_class" {
  description = "The instance class for RDS"
  type        = string
}

variable "rds_allocated_storage" {
  description = "The allocated storage size for RDS"
  type        = number
}

variable "rds_engine_version" {
  description = "The PostgreSQL engine version"
  type        = string
}

variable "rds_admin_username" {
  description = "The admin username for the RDS instance"
  type        = string
}

variable "rds_db_name" {
  description = "The initial database name"
  type        = string
}

variable "rds_security_group_name" {
  description = "The name of the security group for the RDS instance"
  type        = string
}

variable "rds_sg_ingress_security_groups" {
  description = "List of security group IDs with their descriptions"
  type = list(object({
    security_group_id = string
    description       = string
  }))
}
variable "data_subnet_ids" {
  description = "List of data subnet IDs where the RDS instance will be deployed"
  type        = list(string)
}

variable "rds_backup_retention_period" {
  description = "The number of days to retain backups"
  type        = number
}

variable "rds_storage_autoscale" {
  description = "Enable storage autoscaling"
  type        = bool
}

variable "rds_max_allocated_storage" {
  description = "The maximum storage size allowed for autoscaling"
  type        = number
}

variable "performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "environment" {
  description = "The environment to deploy (e.g., dev, stage, prod)"
  type        = string
}

variable "cost_center" {
  description = "The cost center associated with the resources"
  type        = string
}

variable "created_by" {
  description = "The name of the person or automation creating this resource"
  type        = string
  default     = "terraform"
}

variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "eu-north-1"  
}

variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "snapshot_identifier" {
  description = "Optional snapshot identifier to restore RDS from a snapshot. Defaults to empty, meaning no snapshot is used."
  type        = string
  default     = "" 
}


