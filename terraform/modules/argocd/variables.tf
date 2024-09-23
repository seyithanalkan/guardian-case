variable "kubernetes_host" {
  type        = string
  description = "The Kubernetes API server endpoint"
}

variable "kubernetes_token" {
  type        = string
  description = "OIDC token for authenticating with the Kubernetes API"
}

variable "kubernetes_ca_certificate" {
  type        = string
  description = "Base64-encoded CA certificate for the Kubernetes cluster"
}


variable "namespace" {
  description = "Namespace where ArgoCD will be deployed"
  type        = string
  default     = "argocd"
}

variable "service_account_name" {
  description = "Service account name for ArgoCD"
  type        = string
  default     = "argocd-service-account"
}

variable "argocd_admin_password" {
  description = "The admin password for ArgoCD"
  type        = string
}
