variable "aws_region" {
  type        = string
  description = "The AWS region where the EKS cluster is running"
}

variable "environment" {
  description = "The environment (e.g., dev, prod)"
  type        = string
}

variable "project" {
  description = "The project name"
  type        = string
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
}

variable "created_by" {
  description = "Who created the resources"
  type        = string
}

variable "cluster_name" {
  description = "The name of the EKS cluster"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs"
  type        = list(string)
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}

variable "desired_size" {
  description = "Desired number of worker nodes"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of worker nodes"
  type        = number
  default     = 5
}

variable "min_size" {
  description = "Minimum number of worker nodes"
  type        = number
  default     = 1
}


variable "aws_account_id" {
  description = "AWS Account ID for RBAC"
}

variable "admin_users" {
  type    = list(string)
  default = []  
}