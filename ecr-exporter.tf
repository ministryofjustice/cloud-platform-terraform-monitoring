

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
    value = aws_iam_role.ecr_exporter.name
  }

  set {
    name  = "aws.region"
    value = "eu-west-2"
  }

  depends_on = [
    var.dependence_deploy,
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
  name   = "ecr-exporter"
  role   = aws_iam_role.ecr_exporter.id
  policy = data.aws_iam_policy_document.ecr_exporter.json
}