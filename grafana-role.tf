######################
# Grafana Cloudwatch #
######################

# Grafana datasource for cloudwatch
# Ref: https://github.com/grafana/helm-charts/blob/main/charts/grafana/values.yaml

# Minimal policy permissions 
# Ref: https://grafana.com/docs/grafana/latest/datasources/aws-cloudwatch/

resource "aws_iam_policy" "grafana_datasource" {

  name_prefix = "grafana"
  description = "EKS grafana datasource policy for cluster ${var.cluster_domain_name}"
  policy      = data.aws_iam_policy_document.grafana_datasource_irsa.json
}

data "aws_iam_policy_document" "grafana_datasource_irsa" {
  statement {
    actions = [
      "logs:DescribeLogGroups",
      "logs:GetLogGroupFields",
      "logs:StartQuery",
      "logs:StopQuery",
      "logs:GetQueryResults",
      "logs:GetLogEvents"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:DescribeAlarmsForMetric",
      "cloudwatch:DescribeAlarmHistory",
      "cloudwatch:DescribeAlarms",
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricData",
      "cloudwatch:GetInsightRuleReport"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "ec2:DescribeTags",
      "ec2:DescribeInstances",
      "ec2:DescribeRegions"
    ]
    resources = ["*"]
  }
  statement {
    actions = [
      "tag:GetResources",
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.grafana_role.arn]
  }
}

# Create role referencing iam-assumable-role-with-oidc,
# as "allow_self_assume_role" is only available on latest module which have a dependency of terraform version >1
# IRSA

locals {
  aws_account_id = data.aws_caller_identity.current.account_id
  role_name      = "grafana.${var.cluster_domain_name}"
}

data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "assume_role_with_oidc" {
  statement {
    # https://aws.amazon.com/blogs/security/announcing-an-update-to-iam-role-trust-policy-behavior/

    sid     = "ExplicitSelfRoleAssumption"
    effect  = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = ["*"]
    }
    condition {
      test     = "ArnLike"
      variable = "aws:PrincipalArn"
      values   = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${local.role_name}"]
    }

  }
  statement {

    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"

      identifiers = ["arn:aws:iam::${local.aws_account_id}:oidc-provider/${var.eks_cluster_oidc_issuer_url}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${var.eks_cluster_oidc_issuer_url}:sub"
      values   = ["system:serviceaccount:monitoring:prometheus-operator-grafana"]
    }
  }
}

resource "aws_iam_role" "grafana_role" {

  name                 = "grafana.${var.cluster_domain_name}"
  description          = "iam-assumable-role-with-oidc"
  max_session_duration = "3600"

  assume_role_policy = data.aws_iam_policy_document.assume_role_with_oidc.json

  tags = {
    Terraform = "true"
    Cluster   = var.cluster_domain_name
  }
}

resource "aws_iam_role_policy_attachment" "custom" {

  role       = aws_iam_role.grafana_role.name
  policy_arn = aws_iam_policy.grafana_datasource.arn
}