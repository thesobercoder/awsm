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

func SwitchProfile(profile string, login bool) (string, error) {
	if login {
		if err := ExecSilent("aws", "sso", "login", "--profile", profile, "--no-cli-pager"); err != nil {
			return "", err
		}
	} else {
		if err := ExecSilent("aws", "s3", "ls", "--profile", profile, "--no-cli-pager"); err != nil {
			err = ExecSilent("aws", "sso", "login", "--profile", profile, "--no-cli-pager")
			if err != nil {
				return "", err
			}
		}
	}

	accountId, err := ExecWithOutput("aws", "configure", "get", "sso_account_id", "--profile", profile, "--no-cli-pager")
	if err != nil {
		return "", err
	}

	region, err := ExecWithOutput("aws", "configure", "get", "region", "--profile", profile, "--no-cli-pager")
	if err != nil {
		return "", err
	}

	envVars := make(map[string]string)
	envVars["AWS_PROFILE"] = profile
	envVars["AWS_DEFAULT_PROFILE"] = profile
	envVars["AWS_EB_PROFILE"] = profile
	if accountIdStr := strings.TrimSpace(string(accountId)); accountIdStr != "" {
		envVars["AWS_ACCOUNT"] = accountIdStr
	}
	if regionStr := strings.TrimSpace(string(region)); regionStr != "" {
		envVars["AWS_REGION"] = regionStr
		envVars["AWS_DEFAULT_REGION"] = regionStr
	}

	path, err := WriteEnvFile(envVars)
	if err != nil {
		return "", err
	}

	return path, nil
}
