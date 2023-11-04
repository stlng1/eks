# create namespace for artifactory

resource "kubernetes_namespace" "jfrog" {
  metadata {
    annotations = {
      name = "jfrog-annotation"
    }

    # labels = {
    #   mylabel = "label-value"
    # }

    name = "jfrog"
  }
}


## create iam role for artifactory service account

# data "aws_iam_policy_document" "artifactory_service_account_assume_role_policy" {
#   "Version": "2012-10-17",
#   "Statement": [
#       {
#           "Sid": "",
#           "Effect": "Allow",
#           "Principal": {
#                "Federated": "arn:aws:iam:::oidc-provider/oidc.eks.eu-west-3.amazonaws.com/id/"
#           },
#           "Action": "sts:AssumeRoleWithWebIdentity",
#           "Condition": {
#               "StringEquals": {
#                   "oidc.eks..amazonaws.com/id/:aud": "sts.amazonaws.com",
#                    "oidc.eks..amazonaws.com/id/:sub": "system:serviceaccount:jfrog:artifactory-sa"
#               }
#           }
#       }
#   ]
# }

data "aws_iam_policy_document" "artifactory_service_account_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.eks-cluster.url, "https://", "")}:sub"
      values   = ["system:serviceaccount:jfrog:artifactory-sa"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.eks-cluster.arn]
      type        = "Federated"
    }
  }
}

resource "aws_iam_role" "artifactory_service_account_role" {
  assume_role_policy = data.aws_iam_policy_document.artifactory_service_account_assume_role_policy.json
  name               = "artifactory_service_account_role"
}

# resource "aws_iam_role_policy_attachment" "artifactory_service_account_policy_attachment" {
#   role       = aws_iam_role.artifactory_service_account_role.name
#   policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
# }


