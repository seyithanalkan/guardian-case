variable "vpc_id" {
  description = "The VPC ID where the security group will be created"
  type        = string
}

variable "sg_name" {
  description = "The name of the security group"
  type        = string
}

variable "description" {
  description = "Description of the security group"
  type        = string
  default     = "Managed by Terraform"
}

variable "ingress_rules" {
  description = "List of ingress rules"
  type = list(object({
    from_port                = number
    to_port                  = number
    protocol                 = string
    cidr_blocks              = optional(list(string), [])
    source_security_group_id = optional(string, "")
    description              = optional(string, "")
  }))
}
variable "egress_rules" {
  description = "List of egress rules"
  type = list(object({
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
    source_security_group_id = optional(string, null)
    description              = optional(string, "")
  }))
}
variable "project" {
  description = "The name of the project"
  type        = string
}

variable "cost_center" {
  description = "The cost center associated with the instance"
  type        = string
}

variable "environment" {
  description = "The environment to deploy the instance in"
  type        = string
}

variable "created_by" {
  description = "The name of the person or automation creating this resource"
  type        = string
  default     = "terraform"
}