variable "vpc_id" {
  type = string
}

variable "vpc_cidr" {
  type = string
}

variable "availability_zones" {
  type = list(string)
}

variable "subnet_type" {
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
variable "subnet_offset" {
  description = "Offset to apply to subnet calculation for different subnet types"
  type        = number
}

variable "created_by" {
  type = string
  default = "Terraform"
}
