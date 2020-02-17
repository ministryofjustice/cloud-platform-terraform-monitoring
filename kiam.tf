
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
      "arn:aws:s3:::cloud-platform-2b5483a8020c73862c69b87f44c398b8/*",
      "arn:aws:s3:::cloud-platform-2b5483a8020c73862c69b87f44c398b8"
    ]
  }
}

resource "aws_iam_role_policy" "monitoring" {
  name   = "route53"
  role   = aws_iam_role.monitoring.id
  policy = data.aws_iam_policy_document.monitoring.json
}

###########
# Grafana #
###########

# Grafana datasource for cloudwatch
# Ref: https://github.com/helm/charts/blob/master/stable/grafana/values.yaml

data "aws_iam_policy_document" "grafana_datasource_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "grafana_datasource" {
  name               = "datasource.${data.terraform_remote_state.cluster.outputs.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.grafana_datasource_assume.json
}

# Minimal policy permissions 
# Ref: https://grafana.com/docs/grafana/latest/features/datasources/cloudwatch/#iam-policies

data "aws_iam_policy_document" "grafana_datasource" {
  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:GetMetricData",
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["sts:AssumeRole"]
    resources = [aws_iam_role.grafana_datasource.arn]
  }
}

resource "aws_iam_role_policy" "grafana_datasource" {
  name   = "grafana-datasource"
  role   = aws_iam_role.grafana_datasource.id
  policy = data.aws_iam_policy_document.grafana_datasource.json
}
