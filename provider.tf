terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # version = "~> 4.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = var.aws_region
}

provider "random" {
}

# get EKS authentication for being able to manage k8s objects from terraform
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  token                  = data.aws_eks_cluster_auth.cluster.token
#  load_config_file       = false
}