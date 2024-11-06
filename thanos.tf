resource "helm_release" "thanos" {
  count = var.enable_thanos_helm_chart ? 1 : 0

  name       = "thanos"
  namespace  = kubernetes_namespace.monitoring.id
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "thanos"
  version    = "15.0.0"
  timeout    = 900
  values = [templatefile("${path.module}/templates/thanos-values.yaml.tpl", {
    prometheus_sa_name  = local.prometheus_sa_name
    enabled_compact     = var.enable_thanos_compact
    monitoring_aws_role = module.iam_assumable_role_monitoring.this_iam_role_name
    clusterName         = terraform.workspace
  })]

  depends_on = [
    helm_release.prometheus_operator_eks,
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

# IRSA
module "iam_assumable_role_monitoring" {
  source                        = "terraform-aws-modules/iam/aws//modules/iam-assumable-role-with-oidc"
  version                       = "5.47.1"
  create_role                   = true
  role_name                     = "monitoring.${var.cluster_domain_name}"
  provider_url                  = var.eks_cluster_oidc_issuer_url
  role_policy_arns              = [length(aws_iam_policy.monitoring) >= 1 ? aws_iam_policy.monitoring.arn : ""]
  oidc_fully_qualified_subjects = ["system:serviceaccount:monitoring:prometheus-operator-kube-p-prometheus"]
}

resource "aws_iam_policy" "monitoring" {

  name_prefix = "monitoring"
  description = "EKS monitoring policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.monitoring.json
}
