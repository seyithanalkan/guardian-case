variable "repo_name" {
  description = "The name of the repository"
  type        = string
}

variable "repo_url" {
  description = "The URL of the repository"
  type        = string
}

variable "repo_username" {
  description = "The username for the repository (if required)"
  type        = string
  default     = ""  # Varsayılan değer boş
}

variable "repo_password" {
  description = "The password for the repository (if required)"
  type        = string
  default     = ""  # Varsayılan değer boş
}

variable "argocd_namespace" {
  description = "The namespace where ArgoCD is deployed"
  type        = string
  default     = "argocd"  
}