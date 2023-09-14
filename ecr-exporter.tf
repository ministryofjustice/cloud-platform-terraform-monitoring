################
# ECR Exporter #
################

resource "helm_release" "ecr_exporter" {
  count = var.enable_ecr_exporter ? 1 : 0

  name       = "ecr-exporter"
  namespace  = kubernetes_namespace.monitoring.id
  chart      = "prometheus-ecr-exporter"
  version    = "0.4.0"
  repository = "https://ministryofjustice.github.io/cloud-platform-helm-charts"

  set {
    name  = "serviceAccount.name"
    value = local.ecr_exporter_sa
  }

  set {
    name  = "serviceMonitor.enabled"
    value = true
  }

  set {
    name  = "aws.role"
    value = module.iam_assumable_role_ecr_exporter.this_iam_role_name
  }

  set {
    name  = "aws.region"
    value = "eu-west-2"
  }

  depends_on = [
    local.prometheus_dependency,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

################
# ECR Exporter #
################
data "aws_iam_policy_document" "ecr_exporter" {
  statement {
    actions = [
      "ecr:DescribeRepositories",
      "ecr:ListImages",
    ]

    resources = ["*"]
  }
}


resource "aws_iam_policy" "ecr_exporter" {
  count = var.enable_ecr_exporter ? 1 : 0

  name_prefix = "cloudwatch_exporter"
  description = "EKS ECR Exporter policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.ecr_exporter.json
}

# IRSA
module "irsa" {
  count = var.enable_ecr_exporter ? 1 : 0
  source           = "github.com/ministryofjustice/cloud-platform-terraform-irsa?ref=2.0.0"
  eks_cluster_name = terraform.workspace
  namespace        = kubernetes_namespace.monitoring.id
  role_policy_arns = {
    irsa = aws_iam_policy.ecr_exporter.arn
  }
  service_account_name = local.ecr_exporter_sa
}

