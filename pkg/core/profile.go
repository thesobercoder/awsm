package core

import (
	"os/exec"
	"strings"
)

func ListProfiles() ([]string, error) {
	data, err := exec.Command("aws", "--no-cli-pager", "configure", "list-profiles").Output()
	if err != nil {
		return nil, err
	}

	profiles := strings.Split(string(data), "\n")
	validProfiles := []string{}
	for _, profile := range profiles {
		if profile != "" {
			validProfiles = append(validProfiles, profile)
		}
	}

	return validProfiles, nil
}

func SwitchProfile(profile string) (string, error) {
	err := exec.Command("aws", "s3", "ls", "--profile", profile, "--no-cli-pager").Run()
	if err != nil {
		err = exec.Command("aws", "sso", "login", "--profile", profile, "--no-cli-pager").Run()
		if err != nil {
			return "", err
		}
	}

	accountId, err := exec.Command("aws", "configure", "get", "sso_account_id", "--profile", profile, "--no-cli-pager").Output()
	if err != nil {
		return "", err
	}

	region, err := exec.Command("aws", "configure", "get", "region", "--profile", profile, "--no-cli-pager").Output()
	if err != nil {
		return "", err
	}

	envVars := map[string]string{
		"AWS_PROFILE":         profile,
		"AWS_DEFAULT_PROFILE": profile,
		"AWS_EB_PROFILE":      profile,
		"AWS_ACCOUNT":         strings.TrimSpace(string(accountId)),
		"AWS_REGION":          strings.TrimSpace(string(region)),
		"AWS_DEFAULT_REGION":  strings.TrimSpace(string(region)),
	}

	path, err := WriteEnvFile(envVars)
	if err != nil {
		return "", err
	}

	return path, nil
}
