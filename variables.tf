
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

variable "enable_thanos" {
  description = "Enable or not Thanos"
  default     = false
  type        = bool
}