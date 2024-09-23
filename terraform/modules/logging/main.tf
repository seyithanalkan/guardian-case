# Define the Kubernetes Namespace for Fluent Bit
resource "kubernetes_namespace" "amazon_cloudwatch" {
  metadata {
    name = "amazon-cloudwatch"
  }
}

# Deriving Fluent Bit Read/Write Configurations
locals {
  fluentbit_read_from_tail = var.fluentbit_read_from_head == "On" ? "Off" : "On"
  fluentbit_http_server    = var.fluentbit_http_port == "" ? "Off" : "On"
}

data "aws_region" "current" {}
# Create the Fluent Bit cluster info ConfigMap
resource "kubernetes_config_map" "fluent_bit_cluster_info" {
  metadata {
    name      = "fluent-bit-cluster-info"
    namespace = kubernetes_namespace.amazon_cloudwatch.metadata[0].name
  }

  data = {
    "cluster.name"  = var.cluster_name
    "http.server"   = local.fluentbit_http_server
    "http.port"     = var.fluentbit_http_port
    "read.head"     = var.fluentbit_read_from_head
    "read.tail"     = local.fluentbit_read_from_tail
    "logs.region"   = data.aws_region.current.name
  }
}


resource "null_resource" "apply_fluent_bit" {
  provisioner "local-exec" {
    command = <<EOT
  
    aws eks update-kubeconfig --name ${var.cluster_name} --region ${data.aws_region.current.name}

    kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/fluent-bit/fluent-bit.yaml --validate=false
    EOT
  }
}