resource "helm_release" "rds_exporter" {
  count = var.enable_rds_exporter ? 1 : 0

  name       = "rds-exporter"
  namespace  = kubernetes_namespace.monitoring.id
  chart      = "prometheus-rds-exporter-chart"
  version    = "0.10.1"
  repository = "oci://public.ecr.aws/qonto"

  set = [
    {
      name  = "serviceAccount.create"
      value = false
    },
    {
      name  = "serviceAccount.name"
      value = local.rds_exporter_sa
    },
    {
      name  = "serviceMonitor.enabled"
      value = true
    },
    {
      name = "serviceMonitor.interval"
      value = "240s"
    },
    {
      name = "serviceMonitor.scrapeTimeout"
      value = "240s"
    },
    {
      name  = "aws.region"
      value = "eu-west-2"
    },
    {
      name = "resources.requests.cpu"
      value = "200m"
    },
    {
      name = "resources.requests.memory"
      value = "500Mi"
    },
    {
      name = "resources.limits.cpu"
      value = "2000m"
    },
    {
      name = "resources.limits.memory"
      value = "1Gi"
    }
  ]

  depends_on = [
    local.prometheus_dependency,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

data "aws_iam_policy_document" "rds_exporter" {
statement {
    sid    = "AllowInstanceAndLogDescriptions"
    effect = "Allow"
    actions = [
      "rds:DescribeDBInstances",
      "rds:DescribeDBLogFiles",
    ]
    resources = [
      "arn:aws:rds:*:*:db:*",
    ]
  }

  statement {
    sid    = "AllowMaintenanceDescriptions"
    effect = "Allow"
    actions = [
      "rds:DescribePendingMaintenanceActions",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowGettingCloudWatchMetrics"
    effect = "Allow"
    actions = [
      "cloudwatch:GetMetricData",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowRDSUsageDescriptions"
    effect = "Allow"
    actions = [
      "rds:DescribeAccountAttributes",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowQuotaDescriptions"
    effect = "Allow"
    actions = [
      "servicequotas:GetServiceQuota",
    ]
    resources = ["*"]
  }

  statement {
    sid    = "AllowInstanceTypesDescriptions"
    effect = "Allow"
    actions = [
      "ec2:DescribeInstanceTypes",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "rds_exporter" {
  count = var.enable_rds_exporter ? 1 : 0

  name_prefix = "rds_exporter"
  description = "EKS RDS Exporter policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.rds_exporter.json
}

module "rds_exporter_irsa" {
  count            = var.enable_rds_exporter ? 1 : 0
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.1.0"
  eks_cluster_name = terraform.workspace
  namespace        = kubernetes_namespace.monitoring.id
  role_policy_arns = {
    irsa = aws_iam_policy.rds_exporter[0].arn
  }
  service_account_name = local.rds_exporter_sa

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}
