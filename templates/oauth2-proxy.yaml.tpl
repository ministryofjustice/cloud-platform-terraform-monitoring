#
# This is a redacted version of the upstream values.yaml file found here:
# https://github.com/helm/charts/blob/dea84cfd139f0e7bd7721abfa53e4853c1379c0a/stable/oauth2-proxy/values.yaml
#
replicaCount: 2

config:
  clientID:
  clientSecret:
  cookieSecret:
  # Custom configuration file: oauth2_proxy.cfg
  # configFile: |-
  #   pass_basic_auth = false
  #   pass_access_token = true
  configFile: ""

image:
  imagePullSecrets:
  - name: "dockerhub-credentials"
extraArgs:
  provider: oidc
  oidc-issuer-url: ${issuer_url}
  email-domain: "*"
  upstream: "${upstream}"
  http-address: "0.0.0.0:4180"
  skip-auth-regex: "${exclude_paths}"
  cookie-expire: "7h"
  skip-provider-button: true
  pass-basic-auth: "false"
  pass-host-header: "false"

ingress:
  enabled: true
  className: default
  annotations: {
    external-dns.alpha.kubernetes.io/aws-weight: "100",
    external-dns.alpha.kubernetes.io/set-identifier: "dns-${clusterName}",
    cloud-platform.justice.gov.uk/ignore-external-dns-weight: "true"
  }
  path: /
%{ if ingress_redirect ~}
  hosts:
    - "${hostname}"
    - "${live_domain_hostname}"
  tls:
    - hosts:
      - "${hostname}"
      - "${live_domain_hostname}"
%{ else ~}
  hosts:
    - "${hostname}"
  tls:
    - hosts:
      - "${hostname}"
%{ endif ~}
serviceAccount:
  enabled: true

securityContext:
  enabled: true
  runAsNonRoot: true
  allowPrivilegeEscalation: false
  runAsUser: 2000

sessionStorage:
  # Can be one of the supported session storage cookie/redis
  type: redis
redis:
  # provision an instance of the redis sub-chart
  enabled: true
  architecture: standalone
  image:
    registry: docker.io
    repository: bitnamilegacy/redis
    tag: 7.2.4-debian-11-r5
    pullPolicy: IfNotPresent

########################################
# bitnami legacy images issue:
#
# Bitnami's introduction of 'production-ready' secure images topic:
# https://github.com/bitnami/charts/issues/35164
# 
# As a temp measure we are switching over to legacy registry. This means the chart complains about insecure images (this is by Bitnami design):
#
# ERROR: Original containers have been substituted for unrecognized ones. Deploying this chart with non-standard containers is likely to cause degraded security and performance, broken chart features, and missing environment variables.
# 
# Unrecognized images:
#    - docker.io/bitnamilegacy/redis-7.2.4-debian-11-r5
#
# If you are sure you want to proceed with non-standard containers, you can skip container image verification by setting the global parameter 'global.security.allowInsecureImages' to true.
# Further information can be obtained at https://github.com/bitnami/charts/issues/30850
#
# Therefore we are setting: 
# global.security.allowInsecureImages: true
# 
# This solution will only help us until we pass version 8.0.3 of redis:
# https://hub.docker.com/r/bitnamilegacy/redis/tags
#
# After which we need to do something else:
# 
# - Investigate alternatives
# - subscribe to bitnami?
#
########################################

priorityClassName: system-cluster-critical

global:
  security:
    allowInsecureImages: true

########################################
# bitnami legacy image:
# wait-for-redis initContainer 
########################################

initContainers:
  # if the redis sub-chart is enabled, wait for it to be ready
  # before starting the proxy
  # creates a role binding to get, list, watch, the redis master pod
  # if service account is enabled
  waitForRedis:
    enabled: true
    image:
      repository: "docker.io/bitnamilegacy/kubectl"
      pullPolicy: "IfNotPresent"
    # uses the kubernetes version of the cluster
    # the chart is deployed on, if not set
    kubectlVersion: ""