package main

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestTerraformPlan(t *testing.T) {
	terraformOptions := &terraform.Options{
		TerraformDir: "../",
		Vars: map[string]any{
			"cluster_domain_name":                        "prometheus.cloud-platform.service.justice.gov.uk",
			"alertmanager_slack_receivers":               []string{},
			"pagerduty_config":                           "dummy",
			"enable_ecr_exporter":                        "false",
			"enable_cloudwatch_exporter":                 "false",
			"enable_thanos_helm_chart":                   "false",
			"enable_thanos_sidecar":                      "false",
			"enable_prometheus_affinity_and_tolerations": "false",
			"enable_large_nodesgroup":                    "false",
			"enable_thanos_compact":                      "false",
			"oidc_components_client_id":                  "XXX",
			"oidc_components_client_secret":              "XXX",
			"oidc_issuer_url":                            "https://justice-cloud-platform.eu.auth0.com/",
		},
	}

	terraform.InitAndPlan(t, terraformOptions)
}
