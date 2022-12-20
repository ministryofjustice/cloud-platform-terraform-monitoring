
##
replicas: 1

##
rbac:
  ## @param rbac.create Enable RBAC authentication
  ##
  create: true
## Pods Service Account
## ref: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/
##
serviceAccount:
  ## @param serviceAccount.create Specifies whether a ServiceAccount should be created
  ##
  create: true
##
apiService:
  ## @param apiService.create Specifies whether the v1beta1.metrics.k8s.io API service should be created. You can check if it is needed with `kubectl get --raw "/apis/metrics.k8s.io/v1beta1/nodes"`.
  ## This is still necessary up to at least k8s version >= 1.21, but depends on vendors and cloud providers.
  ##
  create: true

##
hostNetwork: true
##
extraArgs:
  kubelet-insecure-tls: true
  kubelet-preferred-address-types: InternalIP
##

##
service:
  ## @param service.type Kubernetes Service type
  ##
  type: ClusterIP
  ## @param service.port Kubernetes Service port
  ##
  port: 443
  ## @param service.nodePort Kubernetes Service port
  ## ref: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport
  ## e.g:
  ## nodePort: 30001
  ##

livenessProbe:
  enabled: true
  failureThreshold: 3
  httpGet:
    path: /livez
    port: https
    scheme: HTTPS
  periodSeconds: 10

readinessProbe:
  enabled: true
  failureThreshold: 3
  httpGet:
    path: /readyz
    port: https
    scheme: HTTPS
  periodSeconds: 10
