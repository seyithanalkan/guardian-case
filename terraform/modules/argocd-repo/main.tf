resource "kubernetes_manifest" "argocd_repository" {
  manifest = {
    apiVersion = "v1"
    kind      = "Secret"
    metadata = {
      name      = var.repo_name
      namespace = var.argocd_namespace
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
    }
    stringData = {
      url      = var.repo_url
      insecure = "true"
    }
  }

  
}