module "fluent_bit" {
  source = "../modules/logging"  # Adjust the path to your Fluent Bit module

  cluster_name            = module.eks_cluster.cluster_name
  region_name             = var.region
  fluentbit_read_from_head = var.fluentbit_read_from_head
  fluentbit_http_port      = var.fluentbit_http_port
}

