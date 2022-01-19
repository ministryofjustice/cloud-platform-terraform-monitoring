##########
# THANOS #
##########

# Thanos Helm Chart

resource "helm_release" "thanos" {
  count = var.enable_thanos_helm_chart ? 1 : 0

  name      = "thanos"
  namespace = kubernetes_namespace.monitoring.id
  repository = "https://charts.bitnami.com/bitnami"
  chart     = "bitnami/thanos"
#  version   = "8.3.0"
  version = "3.8.3"

  values = [templatefile("${path.module}/templates/thanos-values.yaml.tpl", {
    enabled_compact     = var.enable_thanos_compact
    eks                 = var.eks
    monitoring_aws_role = var.eks ? module.iam_assumable_role_monitoring.this_iam_role_name : aws_iam_role.monitoring.0.name
    clusterName         = terraform.workspace
  })]

  depends_on = [
    local.prometheus_dependency,
  ]

  lifecycle {
    ignore_changes = [keyring]
  }
}

# Kubernetes Secret holding thanos configuration file (this is also used by Prometheus Operator)
resource "kubernetes_secret" "thanos_config" {
  metadata {
    name      = "thanos-objstore-config"
    namespace = kubernetes_namespace.monitoring.id
  }

  data = {
    "thanos.yaml"       = file("${path.module}/templates/thanos-objstore-config.yaml.tpl")
    "object-store.yaml" = file("${path.module}/templates/thanos-objstore-config.yaml.tpl")
  }

  type = "Opaque"
}

##############
# IAM / IRSA #
##############

# This is to create a policy which allows Prometheus (thanos to be precise) to have a role to write to S3 without credentials
data "aws_iam_policy_document" "monitoring_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "monitoring" {
  count = var.eks == false ? 1 : 0

  name               = "monitoring.${var.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.monitoring_assume.json
}

data "aws_iam_policy_document" "monitoring" {

  statement {
    actions = [
      "s3:ListBucket",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:PutObject"
    ]

    # Bucket name is hardcoded because it hasn't been created with terraform
    # files inside this repository. Once we are happy with the test we must: 
    # 1. Create S3 bucket from the cp-environments repo (or maybe from here?)
    # 2. Use the output (S3 bucket name) in this policy
    resources = [
      "arn:aws:s3:::cloud-platform-prometheus-thanos/*",
      "arn:aws:s3:::cloud-platform-prometheus-thanos"
    ]
  }
}

resource "aws_iam_role_policy" "monitoring" {
  count = var.eks == false ? 1 : 0

  name   = "thanos.monitoring.${var.cluster_domain_name}"
  role   = aws_iam_role.monitoring.0.id
  policy = data.aws_iam_policy_document.monitoring.json
}

# IRSA
module "iam_assumable_role_monitoring" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "3.13.0"
  create_role                   = var.eks ? true : false
  role_name                     = "monitoring.${var.cluster_domain_name}"
  provider_url                  = var.eks_cluster_oidc_issuer_url
  role_policy_arns              = [var.eks && length(aws_iam_policy.monitoring) >= 1 ? aws_iam_policy.monitoring.0.arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:prometheus-operator-kube-p-prometheus"]
}

resource "aws_iam_policy" "monitoring" {
  count = var.eks ? 1 : 0

  name_prefix = "monitoring"
  description = "EKS monitoring policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.monitoring.json
}
