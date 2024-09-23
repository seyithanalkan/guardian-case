module "eks_cluster" {
  source              = "../modules/eks"
  aws_region          = var.region
  cluster_name        = format("%s-%s-cluster", var.project, var.environment)
  private_subnet_ids  = values(module.private_subnets.subnet_ids)
  instance_type       = var.eks_instance_type
  desired_size        = var.eks_desired_size
  max_size            = var.eks_max_size
  min_size            = var.eks_min_size
  aws_account_id      = var.aws_account_id
  admin_users         = var.admin_users


  project             = var.project
  environment         = var.environment
  created_by          = var.created_by
  cost_center         = var.cost_center
}





