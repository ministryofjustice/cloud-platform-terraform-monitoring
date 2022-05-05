################
# ECR Exporter #
################

resource "helm_release" "ecr_exporter" {
  count = var.enable_ecr_exporter ? 1 : 0

  name       = "ecr-exporter"
  namespace  = kubernetes_namespace.monitoring.id
  chart      = "prometheus-ecr-exporter"
  repository = "https://ministryofjustice.github.io/cloud-platform-helm-charts"

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

# IRSA

module "iam_assumable_role_ecr_exporter" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.13.0"
  create_role                   = var.enable_ecr_exporter ? true : false
  role_name                     = "ecr-exporter.${var.cluster_domain_name}"
  provider_url                  = var.eks_cluster_oidc_issuer_url
  role_policy_arns              = [var.enable_ecr_exporter ? aws_iam_policy.ecr_exporter.0.arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:default"]
}

resource "aws_iam_policy" "ecr_exporter" {
  count = var.enable_ecr_exporter ? 1 : 0

  name_prefix = "cloudwatch_exporter"
  description = "EKS ECR Exporter policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.ecr_exporter.json
}
