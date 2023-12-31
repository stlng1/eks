# create a iam role for eks cluster.
data "aws_iam_policy_document" "eks_cluster_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:eks-service-account-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-cluster.arn]
      type        = "Federated"
    }
  }
}


resource "aws_iam_role" "eks_cluster_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_assume_role_policy.json
  name               = "eks_cluster_role"

  depends_on = [aws_iam_openid_connect_provider.eks-cluster]
}

resource "aws_iam_role_policy_attachment" "eks_cluster_role_policy_attachment" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  depends_on = [aws_iam_role.eks_cluster_role]
}


## create iam role for eks node groups (workers)
data "aws_iam_policy_document" "eks_group_nodes_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:eks-service-account-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-cluster.arn]
      type        = "Federated"
    }
  }
}

# resource "aws_iam_policy" "eks-group-nodes-policy" {
#   name        = "eks-group-nodes-policy"
#   description = "Worker node policy for the ALB Ingress"

#   policy = file("iam-policy.json")
# }

resource "aws_iam_role" "eks-group-nodes" {
  assume_role_policy = data.aws_iam_policy_document.eks_group_nodes_assume_role_policy.json
  name               = "eks-group-nodes"

  depends_on = [aws_iam_openid_connect_provider.eks-cluster]
}


## attach policies to iam eks node group roles
resource "aws_iam_role_policy_attachment" "nodes-AmazonEKSWorkerNodePolicy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-group-nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEKS_CNI_Policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-group-nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonEC2ContainerRegistryReadOnly_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-group-nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes-AmazonS3FullAccess_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.eks-group-nodes.name
}

# resource "aws_iam_role_policy_attachment" "alb-ingress-controller" {
#   policy_arn = aws_iam_policy.eks-group-nodes-policy.arn
#   role       = aws_iam_role.eks-group-nodes.name
# }

## create iam role for eks service account
data "aws_iam_policy_document" "eks_service_account_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:default:eks-service-account-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-cluster.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "eks_service_account_role" {
  assume_role_policy = data.aws_iam_policy_document.eks_service_account_assume_role_policy.json
  name               = "eks_service_account_role"
}

resource "aws_iam_role_policy_attachment" "eks_service_account_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  role       = aws_iam_role.eks_service_account_role.name
}




## create iam role for ebs-csi-driver
data "aws_iam_policy" "ebs_csi_policy" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}

module "irsa-ebs-csi" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version = "4.7.0"
  create_role                   = true
  role_name                     = "AmazonEKSTFEBSCSIRole-${var.cluster_name}"
  provider_url                  = module.eks.oidc_provider
  role_policy_arns              = [data.aws_iam_policy.ebs_csi_policy.arn]
  oidc_fully_qualified_subjects = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
}


# create the IAM OIDC provider for the cluster
resource "aws_iam_openid_connect_provider" "eks-cluster" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.cluster.certificates[0].sha1_fingerprint]
  url             = module.eks.cluster_oidc_issuer_url
}

## create iam role for aws load balancer

module "lb_role" {
 source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

 role_name                              = "${var.env_name}_eks_lb"
 attach_load_balancer_controller_policy = true

 oidc_providers = {
     main = {
     provider_arn               = module.eks.oidc_provider_arn
     namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
     }
 }
 }