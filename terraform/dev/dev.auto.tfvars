############### GENERAL SETTINGS ###############

region                    = "eu-north-1"
environment               = "dev"
project                   = "guardian"
domain_name               = "guardian.local"
cost_center               = "dev"
vpc_cidr                  = "10.0.0.0/16"
vpc_cost_center           = "dev-vpc"
lb_cost_center            = "Load Balancer"
key_name                  = "guardiancom-dev-key-pair"
instance_network_public   = "public"
instance_network_private  = "private"
instance_network_data     = "data"
created_by                = "Terraform"
rate_limit                = 500
aws_account_id = 544167776152

################### RDS SECTION ###############################

rds_cost_center            = "rds-dev"
rds_instance_class         = "db.t3.medium"
rds_allocated_storage      = 20
rds_engine_version         = "16.2"
rds_admin_username         = "guardian_admin"
rds_backup_retention_period = 7
rds_storage_autoscale      = true
rds_max_allocated_storage  = 100
performance_insights_enabled = true
monitoring_role_arn        = "arn:aws:iam::533266956017:role/rds-monitoring-role"

################### ARGOCD ####################
repo_name = "helm-repo"
repo_url  = "https://github.com/seyithanalkan/guardian-case.git"


argocd_namespace            = "argocd"
argocd_service_account_name = "argocd-service-account"
argocd_ingress_host         = "argocd.guardian.local"
ARGOC_ADMIN_PASSWORD = ""
######## ARGOCD BACKEND APP #############
backend_app_name = "backend"
backend_repo_url = "https://github.com/seyithanalkan/guardian-case.git"
backend_target_revision = "master"  
backend_namespace = "backend"
backend_path      = "backend/backend-guardian"

######## ARGOCD FRONTEND APP #############
frontend_app_name      = "frontend"
frontend_repo_url      = "https://github.com/seyithanalkan/guardian-case.git"
frontend_target_revision = "master"
frontend_namespace     = "frontend"
frontend_path          = "frontend/frontend-guardian" 


################### KUBERNETES SECTION #######################


eks_instance_type            = "t3.medium"
eks_desired_size             = 3
eks_max_size                 = 5
eks_min_size                 = 1
admin_users = ["seyithan"]

################### Notificaton ###################

notification_email = "seyithanalkan@gmail.com"

##test##