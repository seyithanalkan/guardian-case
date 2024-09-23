variable "fluentbit_read_from_head" {
  description = "Configure Fluent Bit to read from head (On/Off)"
  type        = string
}

variable "fluentbit_http_port" {
  description = "HTTP port for Fluent Bit"
  type        = string
  default     = "2020"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region_name" {
  description = "AWS region for the EKS cluster"
  type        = string
}