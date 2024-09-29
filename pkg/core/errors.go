// Context represents the context in which an error occurred
package core

import "fmt"

type Context string

const (
	AWSCLICheck        Context = "AWS CLI Check"
	AWSConfigFileCheck Context = "Config File Check"
	AWSProfileListing  Context = "Profile Listing"
)

type AWSMError struct {
	Message string
	Context Context
}

func (e *AWSMError) Error() string {
	return fmt.Sprintf("%s: %s", e.Context, e.Message)
}

func NewAWSMError(message string, context Context) *AWSMError {
	return &AWSMError{
		Message: message,
		Context: context,
	}
}
