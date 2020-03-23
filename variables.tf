
variable "alertmanager_slack_receivers" {
  description = "A list of configuration values for Slack receivers"
  type        = list
}

variable "iam_role_nodes" {
  description = "Nodes IAM role ARN in order to create the KIAM/Kube2IAM"
  type        = string
}

variable "pagerduty_config" {
  description = "Add PagerDuty key to allow integration with a PD service."
}

variable "dependence_deploy" {
  description = "Deploy Module dependences in order to be executed."
}

variable "dependence_opa" {
  description = "OPA module dependences in order to be executed."
}

variable "enable_ecr_exporter" {
  description = "Enable or not ECR exporter"
  default     = false
  type        = bool
}

variable "enable_cloudwatch_exporter" {
  description = "Enable or not Cloudwatch exporter"
  default     = false
  type        = bool
}

variable "enable_thanos_helm_chart" {
  description = "Enable or not Thanos Helm Chart - (do NOT confuse this with thanos sidecar within prometheus-operator)"
  default     = false
  type        = bool
}

variable "enable_thanos_compact" {
  description = "Enable or not Thanos Compact - not semantically concurrency safe and must be deployed as a singleton against a bucket"
  default     = false
  type        = bool
}

variable "enable_prometheus_affinity_and_tolerations" {
  description = "Enable or not Prometheus node affinity (check helm values for the expressions)"
  default     = false
  type        = bool
}
