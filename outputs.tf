
output "helm_prometheus_operator_status" {
  value = helm_release.prometheus_operator.status
}