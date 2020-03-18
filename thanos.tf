##########
# THANOS #
##########

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
  name               = "monitoring.${data.terraform_remote_state.cluster.outputs.cluster_domain_name}"
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
  name   = "route53"
  role   = aws_iam_role.monitoring.id
  policy = data.aws_iam_policy_document.monitoring.json
}

# Kubernetes Secret holding thanos configuration file
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

# Thanos Helm Chart

resource "helm_release" "thanos" {
  name      = "thanos"
  namespace = kubernetes_namespace.monitoring.id
  chart     = "banzaicloud-stable/thanos"
  version   = "0.3.18"

  values = [templatefile("${path.module}/templates/thanos-values.yaml.tpl", {
    enabled_compact     = var.enable_thanos_compact
    monitoring_aws_role = aws_iam_role.monitoring.name
  })]

  depends_on = [helm_release.prometheus_operator]

  lifecycle {
    ignore_changes = [keyring]
  }
}
