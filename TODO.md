# TODO 

- ECR Exporter doesn't have EKS support (IRSA). Adding it involves [updating the Golang AWS library](https://github.com/ministryofjustice/prometheus_ecr_exporter/blob/master/go.mod#L6) that the module is using to at least 1.23.13 (more info in the [the documentation](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts-minimum-sdk.html))
- CloudWatch datasource is not currently working with IRSA, even if the code is there it doesn't work. 
