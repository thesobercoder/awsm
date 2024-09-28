/*
Copyright © 2024 Soham Dasgupta soham@thesobercoder.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
package cmd

import (
	"fmt"
	"os"
	"os/exec"
	"path/filepath"
	"time"

	"github.com/charmbracelet/lipgloss"
	"github.com/spf13/cobra"
	"github.com/thesobercoder/awsm/pkg/ui"
)

// doctorCmd represents the doctor command
var doctorCmd = &cobra.Command{
	Use:   "doctor",
	Short: "Checks if the AWS CLI is installed and configured properly",
	Long: `Checks if AWS CLI is installed and configured properly.

If AWS CLI is not installed, an error message will be displayed.`,
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Print("\n")

		ui.NewSpinner(func() ([]string, error) {
			var messages []string

			var errorStyle = lipgloss.NewStyle().
				Bold(true).
				Foreground(lipgloss.Color("1"))

			var successStyle = lipgloss.NewStyle().
				Bold(true).
				Foreground(lipgloss.Color("2"))

			if _, err := exec.LookPath("aws"); err != nil {
				messages = append(messages, errorStyle.Render("✘ AWS CLI not found in PATH"))
			} else {
				messages = append(messages, successStyle.Render("✔ AWS CLI found in PATH"))
			}

			configFilePath := filepath.Join(os.Getenv("HOME"), ".aws", "config")
			if _, err := os.Stat(configFilePath); os.IsNotExist(err) {
				messages = append(messages, errorStyle.Render(fmt.Sprintf("✘ AWS CLI config file not found at %s", configFilePath)))
			} else {
				messages = append(messages, successStyle.Render(fmt.Sprintf("✔ AWS CLI config file found at %s", configFilePath)))
			}

			time.Sleep(500 * time.Millisecond)
			return messages, nil
		})
	},
}

func init() {
	RootCmd.AddCommand(doctorCmd)
}
