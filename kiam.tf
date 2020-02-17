######################
# Grafana Cloudwatch #
######################

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
  name               = "ecr-exporter.${data.terraform_remote_state.cluster.outputs.cluster_domain_name}"
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

#######################
# Cloudwatch Exporter #
#######################

data "aws_iam_policy_document" "cloudwatch_export_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "AWS"
      identifiers = [var.iam_role_nodes]
    }
  }
}

resource "aws_iam_role" "cloudwatch_exporter" {
  name               = "cloudwatch.${data.terraform_remote_state.cluster.outputs.cluster_domain_name}"
  assume_role_policy = data.aws_iam_policy_document.cloudwatch_export_assume.json
}

data "aws_iam_policy_document" "cloudwatch_exporter" {
  statement {
    actions = [
      "cloudwatch:ListMetrics",
      "cloudwatch:GetMetricStatistics",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch_exporter" {
  name   = "cloudwatch-exporter"
  role   = aws_iam_role.cloudwatch_exporter.id
  policy = data.aws_iam_policy_document.cloudwatch_exporter.json
}


