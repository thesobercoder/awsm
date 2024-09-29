package core

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"strings"

	"github.com/thesobercoder/awsm/pkg/ui"
)

func Doctor() []string {
	messages := []string{}

	if path, err := exec.LookPath("aws"); err != nil {
		messages = append(messages, ui.ErrorStyle.Render("AWS CLI not found in PATH"))
	} else {
		messages = append(messages, ui.SuccessStyle.Render(fmt.Sprintf("AWS CLI found in PATH %s", path)))
	}

	configFilePath := filepath.Join(os.Getenv("HOME"), ".aws", "config")
	if _, err := os.Stat(configFilePath); os.IsNotExist(err) {
		messages = append(messages, ui.ErrorStyle.Render(fmt.Sprintf("AWS CLI config file not found at %s", configFilePath)))
	} else {
		messages = append(messages, ui.SuccessStyle.Render(fmt.Sprintf("AWS CLI config file found at %s", configFilePath)))
	}

	validProfiles, err := ListProfiles()
	if err != nil {
		messages = append(messages, ui.ErrorStyle.Render("Failed to get AWS CLI profiles"))
		return messages
	}

	if len(validProfiles) == 0 {
		messages = append(messages, ui.ErrorStyle.Render("No profiles found in AWS CLI config file"))
	} else {
		messages = append(messages, ui.SuccessStyle.Render(fmt.Sprintf("AWS CLI profiles found: %s", strings.Join(validProfiles, ", "))))
	}

	return messages
}
