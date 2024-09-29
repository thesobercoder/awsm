package core

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

func Doctor() (successMessages []string, errorMessages []*AWSMError) {
	if path, err := exec.LookPath("aws"); err != nil {
		errorMessages = append(errorMessages, NewAWSMError("AWS CLI not found in PATH", AWSCLICheck))
	} else {
		successMessages = append(successMessages, fmt.Sprintf("AWS CLI found in PATH %s", path))
	}

	configFilePath := filepath.Join(os.Getenv("HOME"), ".aws", "config")
	if _, err := os.Stat(configFilePath); os.IsNotExist(err) {
		errorMessages = append(errorMessages, &AWSMError{
			Message: fmt.Sprintf("AWS CLI config file not found at %s", configFilePath),
			Context: AWSConfigFileCheck,
		})
	} else {
		successMessages = append(successMessages, fmt.Sprintf("AWS CLI config file found at %s", configFilePath))
	}

	validProfiles, err := ListProfiles()
	if err != nil {
		errorMessages = append(errorMessages, &AWSMError{
			Message: "Failed to get AWS CLI profiles",
			Context: AWSProfileListing,
		})
		return successMessages, errorMessages
	}

	if len(validProfiles) == 0 {
		errorMessages = append(errorMessages, &AWSMError{
			Message: "No profiles found in AWS CLI config file",
			Context: AWSProfileListing,
		})
	} else {
		successMessages = append(successMessages, fmt.Sprintf("AWS CLI profiles found: %s", strings.Join(validProfiles, ", ")))
	}

	return successMessages, errorMessages
}
