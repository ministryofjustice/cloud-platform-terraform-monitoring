resource "helm_release" "yace_cloudwatch_exporter" {
  count = var.enable_cloudwatch_exporter ? 1 : 0

  name       = "yace-cloudwatch-exporter"
  namespace  = kubernetes_namespace.monitoring.id
  repository = "https://nerdswords.github.io/helm-charts"
  version    = "0.38.0"
  chart      = "yet-another-cloudwatch-exporter"

  values = [templatefile("${path.module}/templates/yace-cloudwatch-exporter.yaml", {
    iam_role            = module.iam_assumable_role_yace_cloudwatch_exporter.iam_role_name
    eks_service_account = module.iam_assumable_role_yace_cloudwatch_exporter.iam_role_arn
  })]

  depends_on = [
    local.prometheus_dependency,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

data "aws_iam_policy_document" "yace_cloudwatch_exporter" {
  statement {
    actions = [
      "tag:GetResources",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "iam:ListAccountAliases"
    ]

    resources = ["*"]
  }
}

module "iam_assumable_role_yace_cloudwatch_exporter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.52.1"
  create_role                   = var.enable_cloudwatch_exporter ? true : false
  role_name                     = "yace.${var.cluster_domain_name}"
  provider_url                  = var.eks_cluster_oidc_issuer_url
  role_policy_arns              = [var.enable_cloudwatch_exporter ? aws_iam_policy.yace_cloudwatch_exporter[0].arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:cloud-platform-yace-cloudwatch-exporter"]
}

resource "aws_iam_policy" "yace_cloudwatch_exporter" {
  count = var.enable_cloudwatch_exporter ? 1 : 0

  name_prefix = "yace_cloudwatch_exporter"
  description = "EKS YACE CloudWatch Exporter policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.yace_cloudwatch_exporter.json
}
