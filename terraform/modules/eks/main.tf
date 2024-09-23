# IAM Policy for the EKS Role (without OIDC initially)
data "aws_iam_policy_document" "eks_assume_role_policy_no_oidc" {
  statement {
    actions = ["sts:AssumeRole"]
    effect  = "Allow"

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# IAM Role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role_policy_no_oidc.json

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ]

  tags = {
    Environment   = var.environment
    Project       = var.project
    Cost_Center   = var.cost_center
    Created_By    = var.created_by
  }
}

# KMS Key for encryption
resource "aws_kms_key" "eks_secrets_kms" {
  description             = "KMS key for EKS cluster secrets encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true
}

resource "aws_kms_alias" "eks_secrets_kms_alias" {
  name          = "alias/eks-secrets-kms"
  target_key_id = aws_kms_key.eks_secrets_kms.id
}

# EKS Cluster Resource
resource "aws_eks_cluster" "eks" {
  name     = var.cluster_name
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  encryption_config {
    provider {
      key_arn = aws_kms_key.eks_secrets_kms.arn
    }
    resources = ["secrets"]
  }

  tags = {
    Environment   = var.environment
    Project       = var.project
    Cost_Center   = var.cost_center
    Created_By    = var.created_by
  }
}

# IAM Role for EKS Worker Nodes
resource "aws_iam_role" "node_group_role" {
  name               = "nodegroup-${var.environment}-${var.project}-iamrole"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        },
        Action = "sts:AssumeRole"
      }
    ]
  })

  managed_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy",
    "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
    "arn:aws:iam::aws:policy/AmazonRDSFullAccess",
    "arn:aws:iam::aws:policy/SecretsManagerReadWrite" 
  ]

  tags = {
    Environment   = var.environment
    Project       = var.project
    Cost_Center   = var.cost_center
    Created_By    = var.created_by
  }
  lifecycle {
    ignore_changes = [
      managed_policy_arns,  # Ignore changes in managed policies
    ]
  }  
}

# EKS Node Group
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "${var.cluster_name}-node-group"
  node_role_arn   = aws_iam_role.node_group_role.arn
  subnet_ids      = var.private_subnet_ids

  scaling_config {
    desired_size = var.desired_size
    max_size     = var.max_size
    min_size     = var.min_size
  }

  instance_types = [var.instance_type]

  tags = {
    Environment   = var.environment
    Project       = var.project
    Cost_Center   = var.cost_center
    Created_By    = var.created_by
    "k8s.io/cluster-autoscaler/enabled" = "true"
    "k8s.io/cluster-autoscaler/${aws_eks_cluster.eks.name}" = "owned"
  }
}

resource "aws_iam_policy" "ecr_pull_policy" {
  name = "ECRPullPolicy"
  description = "Allow EKS nodes to pull images from ECR"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow",
        Action = "ecr:GetAuthorizationToken",
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_pull_policy_attachment" {
  policy_arn = aws_iam_policy.ecr_pull_policy.arn
  role       = aws_iam_role.node_group_role.name
}

# EKS Add-on: CoreDNS, VPC-CNI, and kube-proxy
resource "aws_eks_addon" "coredns" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "coredns"
  addon_version = "v1.11.3-eksbuild.1"
  depends_on = [ aws_eks_node_group.eks_nodes ]

}

resource "aws_eks_addon" "vpc_cni" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "vpc-cni"
}

resource "aws_eks_addon" "kube_proxy" {
  cluster_name  = aws_eks_cluster.eks.name
  addon_name    = "kube-proxy"
}


resource "kubernetes_config_map" "aws_auth" {
  metadata {
    name      = "aws-auth"
    namespace = "kube-system"
  }

  data = {
    mapRoles = <<-YAML
      - rolearn: ${aws_iam_role.node_group_role.arn}
        username: system:node:{{EC2PrivateDNSName}}
        groups:
          - system:bootstrappers
          - system:nodes
    YAML

    mapUsers = <<-YAML
      %{ for user in var.admin_users ~}
      - userarn: arn:aws:iam::${var.aws_account_id}:user/${user}
        username: ${user}
        groups:
          - system:masters
      %{ endfor ~}
    YAML
  }

  lifecycle {
    ignore_changes = all
  }
}




data "aws_eks_cluster" "eks" {
  name       = aws_eks_cluster.eks.name
  depends_on = [aws_eks_cluster.eks]
}


data "tls_certificate" "oidc_thumbprint" {
  url        = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  depends_on = [aws_eks_cluster.eks]
}


resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.oidc_thumbprint.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  depends_on      = [aws_eks_cluster.eks] 
}



resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  namespace  = "kube-system"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  version    = "3.11.0" 

  set {
    name  = "args"
    value = "{--kubelet-insecure-tls,--metric-resolution=30s}"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "200Mi"
  }

  set {
    name  = "resources.limits.cpu"
    value = "200m"
  }

  set {
    name  = "resources.limits.memory"
    value = "400Mi"
  }
}


resource "aws_iam_role" "cluster_autoscaler_role" {
  assume_role_policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "${aws_iam_openid_connect_provider.eks_oidc.arn}"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "${aws_iam_openid_connect_provider.eks_oidc.url}:sub": "system:serviceaccount:kube-system:cluster-autoscaler"
          }
        }
      }
    ]
  }
  EOF
}


resource "aws_iam_policy" "cluster_autoscaler_policy" {
  name        = "ClusterAutoscalerPolicy"
  description = "IAM policy for the cluster autoscaler"

  policy = <<EOF
  {
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "autoscaling:DescribeAutoScalingGroups",
          "autoscaling:DescribeAutoScalingInstances",
          "autoscaling:DescribeLaunchConfigurations",
          "autoscaling:DescribeScalingActivities",
          "autoscaling:DescribeTags",                   
          "autoscaling:CreateOrUpdateTags",  
          "ec2:DescribeImages",
          "ec2:DescribeInstanceTypes",
          "ec2:DescribeLaunchTemplateVersions",
          "ec2:GetInstanceTypesFromInstanceRequirements",
          "eks:DescribeNodegroup"
        ],
        "Resource": "*"
      },
      {
        "Effect": "Allow",
        "Action": [
          "autoscaling:SetDesiredCapacity",
          "autoscaling:TerminateInstanceInAutoScalingGroup"
        ],
        "Resource": "*"
      }
    ]
  }
  EOF
}

resource "aws_iam_role_policy_attachment" "cluster_autoscaler_attach" {
  policy_arn = aws_iam_policy.cluster_autoscaler_policy.arn
  role       = aws_iam_role.cluster_autoscaler_role.name
}




data "aws_iam_policy_document" "cluster_autoscaler_full_permissions" {
  statement {
    effect = "Allow"
    actions = [
      "autoscaling:DescribeAutoScalingGroups",
      "autoscaling:DescribeAutoScalingInstances",
      "autoscaling:DescribeLaunchConfigurations",
      "autoscaling:DescribeScalingActivities",
      "ec2:DescribeImages",
      "ec2:DescribeInstanceTypes",
      "ec2:DescribeLaunchTemplateVersions",
      "ec2:GetInstanceTypesFromInstanceRequirements",
      "eks:DescribeNodegroup"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "autoscaling:SetDesiredCapacity",
      "autoscaling:TerminateInstanceInAutoScalingGroup"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cluster_autoscaler_full_policy" {
  name   = "ClusterAutoscalerFullPolicy"
  role   = aws_iam_role.cluster_autoscaler_role.id
  policy = data.aws_iam_policy_document.cluster_autoscaler_full_permissions.json
}

resource "helm_release" "cluster_autoscaler" {
  name       = "cluster-autoscaler"
  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = "9.37.0"
  namespace  = "kube-system"
  replace    = true

  set {
    name  = "autoDiscovery.clusterName"
    value = aws_eks_cluster.eks.name
  }

  set {
    name  = "autoDiscovery.enabled"
    value = "true"
  }

  set {
    name  = "awsRegion"
    value = var.aws_region
  }

  set {
    name  = "rbac.serviceAccount.create"
    value = "false"
  }

  set {
    name  = "rbac.serviceAccount.name"
    value = "cluster-autoscaler"
  }

  depends_on = [
    aws_eks_cluster.eks,
    aws_iam_role.cluster_autoscaler_role,  
    aws_iam_role_policy_attachment.cluster_autoscaler_attach,
    kubernetes_service_account.cluster_autoscaler
  ]

}

resource "kubernetes_service_account" "cluster_autoscaler" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cluster_autoscaler_role.arn
    }
  }
}

