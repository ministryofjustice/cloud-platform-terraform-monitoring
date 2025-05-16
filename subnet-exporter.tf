resource "helm_release" "subnet_exporter" {
  count = var.enable_subnet_exporter ? 1 : 0

  name       = "subnet-exporter"
  namespace  = kubernetes_namespace.monitoring.id
  chart      = "aws-subnet-exporter"
  version    = "0.1.5"
  repository = "https://ministryofjustice.github.io/cloud-platform-helm-charts/"

  set {
    name  = "image.tag"
    value = var.aws_subnet_exporter_image_tag
  }
  set {
    name  = "awsSubnetExporter.region"
    value = "eu-west-2"
  }

  set {
    name  = "awsSubnetExporter.filter"
    value = "*"
  }
  
  set {
    name  = "serviceAccount.create"
    value = false
  }

  set {
    name  = "serviceAccount.name"
    value = local.subnet_exporter_sa
  }

  set {
    name = "serviceMonitor.enabled"
    value = true
  }

  depends_on = [
    local.prometheus_dependency,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

data "aws_iam_policy_document" "subnet_exporter" {
statement {
    sid    = "AllowDescribeSubnets"
    effect = "Allow"
    actions = [
      "ec2:DescribeSubnets",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribeTags",
    ]
    resources = [
      "*",
    ]
  }
}

resource "aws_iam_policy" "subnet_exporter" {
  count = var.enable_subnet_exporter ? 1 : 0

  name_prefix = "subnet_exporter"
  description = "AWS subnet exporter policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.subnet_exporter.json
}

module "subnet_exporter_irsa" {
  count            = var.enable_subnet_exporter ? 1 : 0
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name = terraform.workspace
  namespace        = kubernetes_namespace.monitoring.id
  role_policy_arns = {
    irsa = aws_iam_policy.subnet_exporter[0].arn
  }
  service_account_name = local.subnet_exporter_sa

  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}