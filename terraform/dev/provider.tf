terraform {
  required_version = ">= 0.13"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.65.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "2.1.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.1.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.1.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "3.1.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = ">= 1.7.0"
    }
  }

  backend "s3" {
    bucket  = "guardian-terraform-dev-bucket"
    key     = "terraform/state/guardian-dev.tfstate"
    region  = "eu-north-1"
    encrypt = true
  }
}

provider "aws" {
  region = var.region
}


data "aws_eks_cluster_auth" "eks" {
  name = module.eks_cluster.cluster_name  
}


provider "kubernetes" {
  host                   = module.eks_cluster.cluster_endpoint  
  token                  = data.aws_eks_cluster_auth.eks.token 
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_ca_certificate) 

  
  
}

provider "helm" {
  kubernetes {
    host                   = module.eks_cluster.cluster_endpoint       
    token                  = data.aws_eks_cluster_auth.eks.token       
    cluster_ca_certificate = base64decode(module.eks_cluster.cluster_ca_certificate)
      
  }
}

provider "kubectl" {
  host                   = module.eks_cluster.cluster_endpoint 
  cluster_ca_certificate = base64decode(module.eks_cluster.cluster_ca_certificate)
  token                  = data.aws_eks_cluster_auth.eks.token
  load_config_file       = false
}

data "kubernetes_service" "argocd_service" {
  metadata {
    name      = "argocd-server"  
    namespace = "argocd"    

  }
  depends_on = [ module.eks_cluster ]
}

