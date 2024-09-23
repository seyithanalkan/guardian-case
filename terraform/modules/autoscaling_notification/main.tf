resource "aws_sns_topic" "this" {
  name = "${var.cluster_name}-autoscaling-topic"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.this.arn
  protocol  = "email"
  endpoint  = var.email_address
}


resource "aws_autoscaling_notification" "asg_notifications" {
  group_names   = [var.asg_name]
  notifications = var.notifications
  topic_arn     = aws_sns_topic.this.arn
}