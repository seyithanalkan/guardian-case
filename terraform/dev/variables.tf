############### GENERAL SETTINGS ###############

variable "region" {
  description = "The AWS region"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "domain_name" {
  description = "The domain name"
  type        = string
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
}

variable "vpc_cost_center" {
  description = "Cost center for VPC"
  type        = string
}

variable "lb_cost_center" {
  description = "Cost center for Load Balancer"
  type        = string
}

variable "key_name" {
  description = "Key pair name for EC2 instances"
  type        = string
}

variable "instance_network_public" {
  description = "Public network for instances"
  type        = string
}

variable "instance_network_private" {
  description = "Private network for instances"
  type        = string
}

variable "instance_network_data" {
  description = "Data network for instances"
  type        = string
}

variable "created_by" {
  description = "Creator of the resources"
  type        = string
}

variable "rate_limit" {
  description = "Rate limit for the application"
  type        = number
}
variable "aws_account_id" {
  description = "AWS Account ID for RBAC"
}



################### EKS SECTION ###############################



variable "eks_instance_type" {
  description = "EC2 instance type for EKS worker nodes"
  type        = string
  
}

variable "eks_desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  
}

variable "eks_max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  
}

variable "eks_min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  
}

variable "admin_users" {
  type    = list(string)
  default = []  
}

################ FLUENTBIT ###############

variable "fluentbit_read_from_head" {
  description = "Configure Fluent Bit to read from head (On/Off)"
  type        = string
  default = "on"
}

variable "fluentbit_http_port" {
  description = "HTTP port for Fluent Bit"
  type        = string
  default     = "2020"
}



##############################################################

############### ARGOCD ##############################

# Kubernetes OIDC Variables (from your cluster creation)


# ArgoCD Variables

variable "argocd_namespace" {
  description = "Namespace where ArgoCD will be deployed"
  type        = string
  default     = "argocd"
}

variable "argocd_service_account_name" {
  description = "Service account name for ArgoCD"
  type        = string
  default     = "argocd-service-account"
}

variable "argocd_ingress_host" {
  description = "The hostname for the ArgoCD ingress"
  type        = string
}

variable "ARGOC_ADMIN_PASSWORD" {
  description = "The hostname for the ArgoCD ingress"
  type        = string
}

variable "repo_name" {
  description = "The name of Helm Repo"
  type        = string
  
}

variable "repo_url" {
  description = "The name of Github Repository"
  type        = string
  
}



################ ARGOCD APPS

######### Backend Job ########

variable "backend_repo_url" {
  description = "The GitHub repository URL for the backend application"
  type        = string
}

variable "backend_target_revision" {
  description = "The branch or tag to deploy from"
  type        = string
  default     = "HEAD"  # Varsayılan olarak HEAD kullanabilirsiniz
}

variable "backend_path" {
  description = "The path to the Helm chart in the repository"
  type        = string
  default     = "backend/helm-chart"  # Varsayılan olarak backend chart'ı
}

variable "backend_namespace" {
  description = "The Kubernetes namespace for the backend application"
  type        = string
}

variable "backend_app_name" {
  description = "The Name for the backend application"
  type        = string
}
variable "backend_service_account_name" {
  description = "The Name for the backend application"
  type        = string
  default = "backend-sa"
}




###########  Frontend JOB #########

variable "frontend_repo_url" {
  description = "The GitHub repository URL for the frontend application"
  type        = string
}

variable "frontend_target_revision" {
  description = "The branch or tag to deploy from"
  type        = string
  default     = "HEAD"  # Varsayılan olarak HEAD kullanabilirsiniz
}

variable "frontend_path" {
  description = "The path to the Helm chart in the repository"
  type        = string
  default     = "frontend/helm-chart"  # Varsayılan olarak frontend chart'ı
}

variable "frontend_namespace" {
  description = "The Kubernetes namespace for the frontend application"
  type        = string
}

variable "frontend_app_name" {
  description = "The Name for the frontend application"
  type        = string
}



################### RDS SECTION ###############################

variable "rds_cost_center" {
  description = "Cost center for RDS"
  type        = string
}

variable "rds_instance_class" {
  description = "RDS instance class"
  type        = string
}

variable "rds_allocated_storage" {
  description = "RDS allocated storage in GB"
  type        = number
}

variable "rds_engine_version" {
  description = "RDS engine version"
  type        = string
}

variable "rds_admin_username" {
  description = "RDS admin username"
  type        = string
}

variable "rds_backup_retention_period" {
  description = "Backup retention period for RDS"
  type        = number
}

variable "rds_storage_autoscale" {
  description = "Whether RDS storage autoscaling is enabled"
  type        = bool
}

variable "rds_max_allocated_storage" {
  description = "Maximum allocated storage for RDS autoscaling"
  type        = number
}

variable "performance_insights_enabled" {
  description = "Enable performance insights for RDS"
  type        = bool
}

variable "monitoring_role_arn" {
  description = "Monitoring role ARN for RDS"
  type        = string
}

##############################################################

################### Notification ###########################

variable "notification_email" {
  description = "The email address to send the autoscaling notifications"
  type        = string
}