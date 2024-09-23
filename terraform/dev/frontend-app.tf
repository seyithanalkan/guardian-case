module "frontend_ecr" {
  source          = "../modules/ecr"
  app_name        = format("%s-%s-ecr", var.frontend_app_name, var.environment)
  environment     = var.environment
  project         = var.project
  cost_center     = var.frontend_app_name
}

module "argocd_app_fronted" {
  source          = "../modules/argocd-app"
  app_name        = var.frontend_app_name
  repo_url        = var.frontend_repo_url
  target_revision = var.frontend_target_revision
  helm_chart_path = var.frontend_path
  namespace       = var.frontend_namespace

  depends_on = [ module.argocd ]
}


