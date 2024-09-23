resource "random_password" "argocd_admin_password" {
  length  = 16
  special = false

}

module "argocd" {
  source         = "../modules/argocd"
  argocd_admin_password  = random_password.argocd_admin_password.result
  kubernetes_host               = module.eks_cluster.cluster_endpoint
  kubernetes_token              = data.aws_eks_cluster_auth.eks.token
  kubernetes_ca_certificate     = module.eks_cluster.cluster_ca_certificate
  depends_on = [ module.eks_cluster ]
}

