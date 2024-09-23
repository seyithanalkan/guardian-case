
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = var.namespace
  }
}


resource "kubectl_manifest" "argocd_application" {
  yaml_body = templatefile("../modules/argocd-app/argocd-application.yaml.tpl", {
    app_name        = var.app_name
    repo_url        = var.repo_url
    target_revision = var.target_revision
    helm_chart_path = var.helm_chart_path
    namespace       = var.namespace
  })

  
}