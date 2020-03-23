
store:
  annotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"
  tolerations:
    - key: "monitoring-node"
      operator: "Equal"
      value: "true"
      effect: "NoSchedule" 

compact:
  enabled: ${enabled_compact}
  annotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"

bucket:
  annotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"

objstoreSecretOverride: thanos-objstore-config
