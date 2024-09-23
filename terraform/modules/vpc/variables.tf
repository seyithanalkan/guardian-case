variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "environment" {
  type = string
}

variable "project" {
  type = string
}

variable "cost_center" {
  type = string
}

variable "created_by" {
  description = "The name of the person or automation creating this resource"
  type        = string
  default     = "terraform"
}