// Context represents the context in which an error occurred
package core

import "fmt"

type AWSMErrorContext string

const (
	EnvironmentError AWSMErrorContext = "Environment Error"
	ExecutionError   AWSMErrorContext = "Execution Error"
	IOError          AWSMErrorContext = "IO Error"
	SystemError      AWSMErrorContext = "System Error"
)

type AWSMError struct {
	Message string
	Context AWSMErrorContext
}

func (e *AWSMError) Error() string {
	return fmt.Sprintf("%s: %s", e.Context, e.Message)
}

func NewAWSMError(message string, context AWSMErrorContext) *AWSMError {
	return &AWSMError{
		Message: message,
		Context: context,
	}
}
