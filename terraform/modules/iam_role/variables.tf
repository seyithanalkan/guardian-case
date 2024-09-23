variable "role_name" {
  description = "The name of the role to create."
  type        = string
}

variable "assume_role_service" {
  description = "The service that can assume this role (e.g., ecs-tasks.amazonaws.com, ec2.amazonaws.com)."
  type        = string
}

variable "policy_arns" {
  description = "A list of policy ARNs to attach to the role."
  type        = list(string)
}

variable "environment" {
  description = "The environment (e.g., prod, dev)."
  type        = string
}

variable "project" {
  description = "The project name."
  type        = string
}

variable "cost_center" {
  description = "The cost center tag."
  type        = string
}

variable "create_instance_profile" {
  description = "Whether to create an instance profile for the role (useful for EC2)."
  type        = bool
  default     = false
}

variable "created_by" {
  description = "The name of the person or automation creating this resource"
  type        = string
  default     = "terraform"
}