variable "subnet_id" {
  type = string
}

variable "allocation_id" {
  type = string
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
  type = string
  default = "Terraform"
}
