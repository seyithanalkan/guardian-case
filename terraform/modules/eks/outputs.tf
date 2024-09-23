
output "cluster_name" {
  value = aws_eks_cluster.eks.name
}


output "cluster_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "cluster_ca_certificate" {
  value = aws_eks_cluster.eks.certificate_authority[0].data 
}

output "node_role_arn" {
  description = "The ARN of the EKS worker node IAM role"
  value       = aws_iam_role.node_group_role.arn
}


output "oidc_issuer_url" {
  value = data.aws_eks_cluster.eks.identity[0].oidc[0].issuer
}

output "oidc_thumbprint" {
  value = data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint
}

output "eks_node_group_security_group" {
  value   = aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id
  description = "The security group ID of the EKS node group."
}