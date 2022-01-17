# Cloudwatch prometheus exporter
# KIAM role creation
# Ref: https://github.com/helm/charts/blob/master/stable/prometheus-cloudwatch-exporter/values.yaml

resource "helm_release" "cloudwatch_exporter" {
  count = var.enable_cloudwatch_exporter ? 1 : 0

  name       = "cloudwatch-exporter"
  namespace  = kubernetes_namespace.monitoring.id
  repository = "https://prometheus-community.github.io/helm-charts"
  version    = "0.18.0"
  chart      = "prometheus-cloudwatch-exporter"

  values = [templatefile("${path.module}/templates/cloudwatch-exporter.yaml", {
    iam_role            = var.eks ? module.iam_assumable_role_cloudwatch_exporter.this_iam_role_name : aws_iam_role.cloudwatch_exporter.0.name
    eks                 = var.eks
    eks_service_account = module.iam_assumable_role_cloudwatch_exporter.this_iam_role_arn
  })]

  depends_on = [
    local.prometheus_dependency,
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

# IRSA

module "iam_assumable_role_cloudwatch_exporter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.13.0"
  create_role                   = var.enable_cloudwatch_exporter && var.eks ? true : false
  role_name                     = "cloudwatch.${var.cluster_domain_name}"
  provider_url                  = var.eks_cluster_oidc_issuer_url
  role_policy_arns              = [var.enable_cloudwatch_exporter && var.eks ? aws_iam_policy.cloudwatch_exporter.0.arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:cloud-platform-cloudwatch-exporter"]
}

resource "aws_iam_policy" "cloudwatch_exporter" {
  count = var.enable_cloudwatch_exporter && var.eks ? 1 : 0

  name_prefix = "cloudwatch_exporter"
  description = "EKS CloudWatch Exporter policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.cloudwatch_exporter.json
}
