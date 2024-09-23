variable "app_name" {
  description = "The application name"
  type        = string
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "environment" {
  description = "The environment (e.g., prod, dev)"
  type        = string
}

variable "cost_center" {
  description = "The cost center associated with the resource"
  type        = string
}

variable "created_by" {
  description = "The name of the person or automation creating this resource"
  type        = string
  default     = "terraform"
}
