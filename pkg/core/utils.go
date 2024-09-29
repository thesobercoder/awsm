package core

import (
	"os"
	"path/filepath"

	"github.com/joho/godotenv"
)

func WriteEnvFile(envVars map[string]string) (string, error) {
	workingDir, err := os.Getwd()
	if err != nil {
		return "", err
	}

	envFilePath := filepath.Join(workingDir, ".awsm", ".env")
	existingEnv, err := godotenv.Read(envFilePath)
	if err != nil {
		if os.IsNotExist(err) {
			existingEnv = make(map[string]string)
		}
	}

	for key, value := range envVars {
		existingEnv[key] = value
	}

	err = godotenv.Write(existingEnv, envFilePath)
	if err != nil {
		return "", err
	}

	return envFilePath, nil
}
