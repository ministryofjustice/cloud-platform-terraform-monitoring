# Cloudwatch prometheus exporter
# KIAM role creation
# Ref: https://github.com/helm/charts/blob/master/stable/prometheus-cloudwatch-exporter/values.yaml

resource "helm_release" "cloudwatch_exporter" {
  count = var.enable_cloudwatch_exporter ? 1 : 0

  name      = "cloudwatch-exporter"
  namespace = kubernetes_namespace.monitoring.id
  chart     = "stable/prometheus-cloudwatch-exporter"

  values = [
    file("${path.module}/resources/cloudwatch-exporter.yaml"),
  ]

  set {
    name  = "aws.role"
    value = var.eks ? "" : aws_iam_role.cloudwatch_exporter.0.name
  }

  depends_on = [
    var.dependence_deploy,
    helm_release.prometheus_operator,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

#######################
# Cloudwatch Exporter #
#######################

data "aws_iam_policy_document" "cloudwatch_export_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "cloudwatch_exporter" {
  count = var.enable_cloudwatch_exporter && var.eks == false ? 1 : 0

  name               = "cloudwatch.${var.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_export_assume.json
}

data "aws_iam_policy_document" "cloudwatch_exporter" {
  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_exporter" {
  count = var.enable_cloudwatch_exporter && var.eks == false ? 1 : 0 

  name   = "cloudwatch-exporter"
  role   = aws_iam_role.cloudwatch_exporter.0.id
  policy = data.aws_iam_policy_document.cloudwatch_exporter.json
}

module "iam_assumable_role_admin" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "~> v2.6.0"
  create_role                   = var.enable_cloudwatch_exporter && var.eks ? true : false
  role_name                     = "cloudwatch.${var.cluster_domain_name}"
  provider_url                  = var.eks_cluster_oidc_issuer_url
  role_policy_arns              = [var.eks ? aws_iam_policy.cert_manager.0.arn : "" ]
  oidc_fully_qualified_subjects = ["system:serviceaccount:cert-manager:cert-manager"]
}

resource "aws_iam_policy" "cert_manager" {
  count = var.enable_cloudwatch_exporter && var.eks ? 1 : 0

  name_prefix = "cert_manager"
  description = "EKS cluster-autoscaler policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.cloudwatch_exporter.json
}
