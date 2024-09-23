
module "backend_ecr" {
  source          = "../modules/ecr"
  app_name        = format("%s-%s-ecr", var.backend_app_name, var.environment)
  environment     = var.environment
  project         = var.project
  cost_center     = var.backend_app_name
}


module "argocd_app_backend" {
  source          = "../modules/argocd-app"
  app_name        = var.backend_app_name
  repo_url        = var.backend_repo_url
  target_revision  = var.backend_target_revision
  helm_chart_path  = var.backend_path
  namespace       = var.backend_namespace

  depends_on = [ module.argocd, module.rds_postgres ]
}



locals {
  oidc_provider_url = replace(module.eks_cluster.oidc_issuer_url, "https://", "")
}


data "aws_iam_policy_document" "eks_oidc_trust" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${var.aws_account_id}:oidc-provider/${local.oidc_provider_url}"]  # Correct OIDC provider format
    }

    condition {
      test     = "StringEquals"
      variable = "${local.oidc_provider_url}:sub"
      values   = ["system:serviceaccount:${var.backend_namespace}:${var.backend_service_account_name}"]  # Correct service account reference
    }
  }
}

resource "aws_iam_role" "eks_pod_role" {
  name               = "${var.project}-${var.environment}-eks-pod-role"
  assume_role_policy = data.aws_iam_policy_document.eks_oidc_trust.json
}

resource "aws_iam_role_policy_attachment" "eks_pod_access" {
  role       = aws_iam_role.eks_pod_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
}

resource "aws_iam_role_policy_attachment" "secrets_manager_access" {
  role       = aws_iam_role.eks_pod_role.name
  policy_arn = "arn:aws:iam::aws:policy/SecretsManagerReadWrite"
}

resource "aws_iam_role_policy" "eks_access_policy" {
  role = aws_iam_role.eks_pod_role.name

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "eks:ListNodegroups",
          "eks:DescribeNodegroup",
          "eks:DescribeCluster",
          "eks:ListClusters"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribePolicies"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeTags",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeNetworkInterfaces"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "kubernetes_service_account" "backend_service_account" {
  metadata {
    name      = var.backend_service_account_name
    namespace = var.backend_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_pod_role.arn 
    }
  }
  depends_on = [ module.argocd_app_backend ]
}
