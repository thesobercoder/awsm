package core

import (
	"os"
	"os/exec"
	"strings"

	"github.com/joho/godotenv"
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
			return "", NewAWSMError("Failed to login via AWS SSO", ExecutionError)
		}
	} else {
		if err := ExecSilent("aws", "s3", "ls", "--profile", profile, "--no-cli-pager"); err != nil {
			err = ExecSilent("aws", "sso", "login", "--profile", profile, "--no-cli-pager")
			if err != nil {
				return "", NewAWSMError("Failed to login via AWS SSO", ExecutionError)
			}
		}
	}

	accountId, err := ExecWithOutput("aws", "configure", "get", "sso_account_id", "--profile", profile, "--no-cli-pager")
	if err != nil {
		return "", NewAWSMError("Failed to get AWS account", ExecutionError)
	}

	region, err := ExecWithOutput("aws", "configure", "get", "region", "--profile", profile, "--no-cli-pager")
	if err != nil {
		return "", NewAWSMError("Failed to get AWS region", ExecutionError)
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
		return "", NewAWSMError("Failed to write environment file", IOError)
	}

	return path, nil
}

func DetectCurrentProfile() (map[string]string, []error) {
	envVars := make(map[string]string)
	var errors []error

	loadEnvironment := func() {
		if value, exists := os.LookupEnv("AWS_PROFILE"); exists {
			envVars["AWS_PROFILE"] = value
		} else {
			errors = append(errors, NewAWSMError("AWS_PROFILE not found in environment", EnvironmentError))
		}

		if value, exists := os.LookupEnv("AWS_DEFAULT_PROFILE"); exists {
			envVars["AWS_DEFAULT_PROFILE"] = value
		} else {
			errors = append(errors, NewAWSMError("AWS_DEFAULT_PROFILE not found in environment", EnvironmentError))
		}

		if value, exists := os.LookupEnv("AWS_EB_PROFILE"); exists {
			envVars["AWS_EB_PROFILE"] = value
		} else {
			errors = append(errors, NewAWSMError("AWS_EB_PROFILE not found in environment", EnvironmentError))
		}

		if value, exists := os.LookupEnv("AWS_REGION"); exists {
			envVars["AWS_REGION"] = value
		} else {
			errors = append(errors, NewAWSMError("AWS_REGION not found in environment", EnvironmentError))
		}

		if value, exists := os.LookupEnv("AWS_DEFAULT_REGION"); exists {
			envVars["AWS_DEFAULT_REGION"] = value
		} else {
			errors = append(errors, NewAWSMError("AWS_DEFAULT_REGION not found in environment", EnvironmentError))
		}
	}

	// Check environment variables directly
	loadEnvironment()

	// Load .env file and check again
	if len(errors) > 0 {
		err := godotenv.Load()
		if err != nil {
			errors = append(errors, NewAWSMError("Error loading .env file", IOError))
		} else {
			// Clear previous errors since they might be resolved with .env file
			errors = nil
			loadEnvironment()
		}
	}

	return envVars, errors
}
