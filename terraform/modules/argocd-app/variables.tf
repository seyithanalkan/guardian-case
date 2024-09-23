variable "app_name" {
  description = "The name of the ArgoCD application"
  type        = string
}

variable "repo_url" {
  description = "The GitHub repository URL for the application"
  type        = string
}

variable "target_revision" {
  description = "The branch or tag to deploy from"
  type        = string
  default     = "HEAD"
}

variable "helm_chart_path" {
  description = "The path to the Helm chart in the repository"
  type        = string
}

variable "namespace" {
  description = "The Kubernetes namespace for the application"
  type        = string
}