
output "helm_prometheus_operator_status" {
  value = length(helm_release.prometheus_operator) > 0 ? helm_release.prometheus_operator[0].status : null
}

output "helm_prometheus_operator_eks_status" {
  value = length(helm_release.prometheus_operator_eks) > 0 ? helm_release.prometheus_operator_eks[0].status : null
}
