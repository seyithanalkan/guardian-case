variable "cluster_name" {
  description = "EKS Cluster name"
  type        = string
}

variable "sns_topic_name" {
  description = "SNS Topic name for autoscaling notifications"
  type        = string
}

variable "email_address" {
  description = "Email address to receive notifications"
  type        = string
}

variable "asg_name" {
  description = "Auto Scaling Group name"
  type        = string
}

variable "notifications" {
  description = "List of notifications to subscribe to"
  type        = list(string)
}