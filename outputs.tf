
output "helm_prometheus_operator_eks_status" {
  value = length(helm_release.prometheus_operator_eks) > 0 ? helm_release.prometheus_operator_eks.status : null
}
