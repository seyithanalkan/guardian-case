resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = "7.5.2"

 
  values = [
    templatefile("${path.module}/values.yaml", {
      admin_password = var.argocd_admin_password  
    })
  ]

  depends_on = [kubernetes_namespace.argocd]
}

resource "kubectl_manifest" "argocd_rbac_configmap" {
  yaml_body = <<YAML
apiVersion: v1
kind: ConfigMap
metadata:
  name: argocd-rbac-cm
  namespace: ${var.namespace}
data:
  policy.csv: |
    g, admin, role:admin
    g,argocd-admins,role:admin
    g,argocd-readers,role:readonly
    g,argocd-deployers,role:admin
    g,my-user,role:admin
YAML

  depends_on = [helm_release.argocd]
}