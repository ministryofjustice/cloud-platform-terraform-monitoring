
store:
  annotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"

compact:
  enabled: ${enabled_compact}
  annotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"

bucket:
  annotations:
    iam.amazonaws.com/role: "${monitoring_aws_role}"

objstoreSecretOverride: thanos-objstore-config