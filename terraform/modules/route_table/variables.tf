variable "vpc_id" {
  description = "The ID of the VPC"
  type        = string
}

variable "gateway_id" {
  description = "The ID of the Internet Gateway (for public route tables)"
  type        = string
}

variable "nat_gateway_id" {
  description = "The ID of the NAT Gateway (for private route tables)"
  type        = string
}

variable "environment" {
  description = "The environment (dev, stage, prod)"
  type        = string
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "cost_center" {
  description = "The cost center"
  type        = string
}

variable "route_type" {
  description = "The type of route (public or private)"
  type        = string
}

variable "subnet_ids" {
  description = "The subnet IDs to associate with the route table"
  type        = list(string)
}

variable "created_by" {
  type = string
  default = "Terraform"
}

