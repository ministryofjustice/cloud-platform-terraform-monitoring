resource "helm_release" "subnet_exporter" {
  count = var.enable_subnet_exporter ? 1 : 0

  name       = "subnet-exporter"
  namespace  = kubernetes_namespace.monitoring.id
  chart      = "aws-subnet-exporter"
  version    = "0.1.5"
  repository = "https://ministryofjustice.github.io/cloud-platform-helm-charts/"

  set = [
    {
      name  = "image.tag"
      value = var.aws_subnet_exporter_image_tag
    },
    {
      name  = "awsSubnetExporter.region"
      value = "eu-west-2"
    },
    {
      name  = "awsSubnetExporter.filter"
      value = "*"
    },
    {
      name  = "serviceAccount.create"
      value = false
    },
    {
      name  = "serviceAccount.name"
      value = local.subnet_exporter_sa
    },
    {
      name = "serviceMonitor.enabled"
      value = true
    }
  ]

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

# IRSA resources for subnet exporter
resource "aws_iam_role" "subnet_exporter" {
  count = var.enable_subnet_exporter ? 1 : 0
  name = "subnet-exporter-irsa-${terraform.workspace}"
  assume_role_policy = data.aws_iam_policy_document.subnet_exporter_assume_role[count.index].json
  tags = {
    business-unit          = var.business_unit
    application            = var.application
    is-production          = var.is_production
    team-name              = var.team_name
    environment-name       = var.environment
    infrastructure-support = var.infrastructure_support
  }
}

data "aws_iam_policy_document" "subnet_exporter_assume_role" {
  count = var.enable_subnet_exporter ? 1 : 0
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [replace(var.eks_cluster_oidc_issuer_url, "https://", "")]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.eks_cluster_oidc_issuer_url, "https://", "")}:sub"
      values   = ["system:serviceaccount:${kubernetes_namespace.monitoring.id}:${local.subnet_exporter_sa}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "subnet_exporter" {
  count      = var.enable_subnet_exporter ? 1 : 0
  role       = aws_iam_role.subnet_exporter[count.index].name
  policy_arn = aws_iam_policy.subnet_exporter[count.index].arn
}


