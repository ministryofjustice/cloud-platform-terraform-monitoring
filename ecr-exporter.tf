

################
# ECR Exporter #
################

resource "helm_release" "ecr_exporter" {
  count = var.enable_ecr_exporter ? 1 : 0

  name       = "ecr-exporter"
  namespace  = kubernetes_namespace.monitoring.id
  chart      = "prometheus-ecr-exporter"
  repository = data.helm_repository.cloud_platform.metadata[0].name

  set {
    name  = "serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "aws.role"
    value = aws_iam_role.ecr_exporter.0.name
  }

  set {
    name  = "aws.region"
    value = "eu-west-2"
  }

  depends_on = [
    helm_release.prometheus_operator,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

################
# ECR Exporter #
################

data "aws_iam_policy_document" "ecr_exporter_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "ecr_exporter" {
  count = var.enable_ecr_exporter && var.eks == false ? 1 : 0
  
  name               = "ecr-exporter.${var.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.ecr_exporter_assume.json
}

data "aws_iam_policy_document" "ecr_exporter" {
  statement {
    actions = [
      "ecr:DescribeRepositories",
      "ecr:ListImages",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "ecr_exporter" {
  count = var.enable_ecr_exporter && var.eks == false ? 1 : 0

  name   = "ecr-exporter"
  role   = aws_iam_role.ecr_exporter.0.id
  policy = data.aws_iam_policy_document.ecr_exporter.json
}

# IRSA

module "iam_assumable_role_ecr_exporter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = var.enable_ecr_exporter && var.eks ? true : false
  role_name                     = "ecr-exporter.${var.cluster_domain_name}"
  provider_url                  = var.eks_cluster_oidc_issuer_url
  role_policy_arns              = [var.enable_ecr_exporter && var.eks ? aws_iam_policy.ecr_exporter.0.arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:test-prometheus-ecr-exporter"]
}

resource "aws_iam_policy" "ecr_exporter" {
  count = var.enable_ecr_exporter && var.eks ? 1 : 0

  name_prefix = "cloudwatch_exporter"
  description = "EKS ECR Exporter policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.cloudwatch_exporter.json
}
