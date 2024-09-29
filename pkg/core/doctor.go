package core

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func Doctor() (successMessages []string, errorMessages []error) {
	if path, err := exec.LookPath("aws"); err != nil {
		errorMessages = append(errorMessages, NewAWSMError("AWS CLI not found in PATH", EnvironmentError))
	} else {
		successMessages = append(successMessages, fmt.Sprintf("AWS CLI found in PATH %s", path))
	}

	configFilePath := filepath.Join(os.Getenv("HOME"), ".aws", "config")
	if _, err := os.Stat(configFilePath); os.IsNotExist(err) {
		errorMessages = append(errorMessages, NewAWSMError(
			fmt.Sprintf("AWS CLI config file not found at %s", configFilePath),
			EnvironmentError,
		))
	} else {
		successMessages = append(successMessages, fmt.Sprintf("AWS CLI config file found at %s", configFilePath))
	}

	validProfiles, err := ListProfiles()
	if err != nil {
		errorMessages = append(errorMessages, NewAWSMError(
			"Failed to get AWS CLI profiles",
			EnvironmentError,
		))
		return successMessages, errorMessages
	}

	if len(validProfiles) == 0 {
		errorMessages = append(errorMessages, NewAWSMError(
			"No profiles found in AWS CLI config file",
			EnvironmentError,
		))
	} else {
		successMessages = append(successMessages, fmt.Sprintf("AWS CLI profiles found: %s", strings.Join(validProfiles, ", ")))
	}

	return successMessages, errorMessages
}
