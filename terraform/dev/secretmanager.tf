resource "aws_secretsmanager_secret" "secret_manager" {
  name        = "${var.project}-${var.environment}-secret-mg"
  description = "Secret manager for ${var.project} in ${var.environment} environment"

  tags = {
    Name        = format("%s-%s-secrets", var.project, var.environment)
    Environment = var.environment
    Project     = var.project
    Cost_Center = var.cost_center
    Created_By  = var.created_by
  }
  depends_on = [ module.argocd ]
}


resource "null_resource" "fetch_argocd_password" {
  provisioner "local-exec" {
    command = <<EOT
      # Update kubeconfig to point to the correct cluster using the module's cluster name
      aws eks update-kubeconfig --name ${module.eks_cluster.cluster_name} --region ${var.region}

      # Fetch the ArgoCD admin password
      PASSWORD=$(kubectl get secret argocd-initial-admin-secret -n argocd -o jsonpath="{.data.password}" | base64 --decode)

      # Store the password in AWS Secrets Manager
      aws secretsmanager put-secret-value --secret-id "${aws_secretsmanager_secret.secret_manager.id}" --secret-string "{\"argocd_admin_password\":\"$PASSWORD\"}"
    EOT
  }
  depends_on = [module.argocd]
}

data "aws_secretsmanager_secret" "manual_secret" {
  name = "${var.project}-${var.environment}-secret-mg"  
  depends_on = [aws_secretsmanager_secret.secret_manager, null_resource.fetch_argocd_password]
}

data "aws_secretsmanager_secret_version" "manual_secret_version" {
  secret_id = data.aws_secretsmanager_secret.manual_secret.id
  depends_on = [aws_secretsmanager_secret.secret_manager, null_resource.fetch_argocd_password]
}


resource "aws_secretsmanager_secret_version" "secret_version" {
  secret_id = aws_secretsmanager_secret.secret_manager.id

  secret_string = jsonencode({
    argocd_admin_password = jsondecode(data.aws_secretsmanager_secret_version.manual_secret_version.secret_string)["argocd_admin_password"]
  
  })

  depends_on = [null_resource.fetch_argocd_password]
  lifecycle {
    ignore_changes = [
      secret_string
    ]
  }  
}