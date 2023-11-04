## create a Kubernetes service account for s3

resource "kubernetes_service_account" "eks-service-account-sa" {
  metadata {
    name = "eks-service-account-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_service_account_role.arn
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks-group-nodes.arn
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_cluster_role.arn

    }
  }
  automount_service_account_token = true
}


## create a Kubernetes service account for ebs-ebs_csi_controller

resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  metadata {
    name = "ebs-csi-controller-sa"
    namespace = "default"
    annotations = {
      "eks.amazonaws.com/role-arn" = module.irsa-ebs-csi.iam_role_arn
  }
}
}

## create a Kubernetes service account for artifactory

resource "kubernetes_service_account" "artifactory_sa" {
  metadata {
    name = "artifactory-sa"
    namespace = "jfrog"
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.artifactory_service_account_role.arn
  }
}
}


## create service account for aws load balancer

resource "kubernetes_service_account" "alb-service-account" {
 metadata {
     name      = "aws-load-balancer-controller"
     namespace = "kube-system"
     labels = {
     "app.kubernetes.io/name"      = "aws-load-balancer-controller"
     "app.kubernetes.io/component" = "controller"
     }
     annotations = {
     "eks.amazonaws.com/role-arn"               = module.lb_role.iam_role_arn
     "eks.amazonaws.com/sts-regional-endpoints" = "true"
     }
 }
 }