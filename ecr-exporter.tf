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
    value = module.iam_assumable_role_ecr_exporter[0].role_arn
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
    irsa = aws_iam_policy.ecr_exporter[0].arn
  }
  service_account_name = local.ecr_exporter_sa

    # Tags
  # Tags
  business_unit          = var.business_unit
  application            = var.application
  is_production          = var.is_production
  team_name              = var.team_name
  environment_name       = var.environment
  infrastructure_support = var.infrastructure_support
}

