data "aws_autoscaling_groups" "asg_by_tag" {
  filter {
    name   = "tag:kubernetes.io/cluster/${module.eks_cluster.cluster_name}"
    values = ["owned"]
  }

  depends_on = [module.eks_cluster]
}

module "autoscaling_notification" {
  source         = "../modules/autoscaling_notification"
  cluster_name   = module.eks_cluster.cluster_name
  sns_topic_name = null 
  email_address  = var.notification_email

  asg_name       = length(data.aws_autoscaling_groups.asg_by_tag.names) > 0 ? data.aws_autoscaling_groups.asg_by_tag.names[0] : "default-asg-name"

  notifications  = [
    "autoscaling:EC2_INSTANCE_LAUNCH",
    "autoscaling:EC2_INSTANCE_TERMINATE",
    "autoscaling:EC2_INSTANCE_LAUNCH_ERROR",
    "autoscaling:EC2_INSTANCE_TERMINATE_ERROR"
  ]

  depends_on = [data.aws_autoscaling_groups.asg_by_tag]
}