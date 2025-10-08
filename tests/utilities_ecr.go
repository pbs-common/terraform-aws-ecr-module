package test

import (
	"fmt"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/stretchr/testify/assert"
)

func testECR(t *testing.T, variant string) {
	t.Parallel()

	terraformDir := fmt.Sprintf("../examples/%s", variant)

	terraformOptions := &terraform.Options{
		TerraformDir: terraformDir,
		LockTimeout:  "5m",
		Upgrade:      true,
	}

	defer terraform.Destroy(t, terraformOptions)

	terraform.InitAndApply(t, terraformOptions)

	url := terraform.Output(t, terraformOptions, "repo_url")

	accountID := getAWSAccountID(t)
	region := getAWSRegion(t)

	expectedName := fmt.Sprintf("example-tf-ecr-%s", variant)
	expectedURL := fmt.Sprintf("%s.dkr.ecr.%s.amazonaws.com/%s", accountID, region, expectedName)

	assert.Equal(t, expectedURL, url)
}
