package main

import (
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
)

func TestDeployMonitoring(t *testing.T) {
	t.Parallel()

	terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
		TerraformDir: "./unit-test",
	})

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	// options := k8s.NewKubectlOptions("", "", "opa")

	// service := k8s.GetService(t, options, "opa")
	// require.Equal(t, service.Name, "opa")
}
