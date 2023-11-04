# get all available AZs in our region
data "aws_availability_zones" "available_azs" {
state = "available"
}

# used for accesing Account ID and ARN
data "aws_caller_identity" "current" {} 

# get EKS cluster info to configure Kubernetes and Helm providers
data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}

data "aws_partition" "current" {}

data "tls_certificate" "cluster" {
  url = module.eks.cluster_oidc_issuer_url
}