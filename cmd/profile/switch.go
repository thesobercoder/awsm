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
	"time"

	"github.com/charmbracelet/huh"
	"github.com/charmbracelet/huh/spinner"
	"github.com/spf13/cobra"
	"github.com/thesobercoder/awsm/pkg/core"
	"github.com/thesobercoder/awsm/pkg/ui"
)

// switchCmd represents the switch command
var switchCmd = &cobra.Command{
	Use:   "switch",
	Short: "A brief description of your command",
	Long: `A longer description that spans multiple lines and likely contains examples
and usage of using your command. For example:

Cobra is a CLI library for Go that empowers applications.
This application is a tool to generate the needed files
to quickly create a Cobra application.`,
	Run: func(cmd *cobra.Command, args []string) {
		var profiles []string
		var path string

		action := func() {
			profiles, _ = core.ListProfiles()
			time.Sleep(time.Millisecond * 500)
		}

		err := spinner.New().
			Title("Searching Profiles").
			Action(action).
			Run()

		if err != nil {
			fmt.Println(ui.ErrorStyle.Render(err.Error()))
			return
		}

		var profile string
		var options []huh.Option[string]
		for _, profile := range profiles {
			options = append(options, huh.NewOption(profile, profile))
		}

		huh.NewSelect[string]().
			Title("Choose Profile").
			Options(options...).
			Value(&profile).
			Run()

		action = func() {
			path, err = core.SwitchProfile(profile, false)
			time.Sleep(time.Millisecond * 500)
		}

		err = spinner.New().
			Title("Switching Profile").
			Action(action).
			Run()

		if err != nil {
			fmt.Println(ui.ErrorStyle.Render(err.Error()))
			return
		}

		fmt.Println(ui.SuccessStyle.Render(fmt.Sprintf("Switched to profile: %s", profile)))
		fmt.Println(ui.SuccessStyle.Render(fmt.Sprintf("Exported AWS profile to %s", path)))
		fmt.Println("")

		command1 := "export $(cat .env | xargs)"
		command2 := "Get-Content .env | ForEach-Object { $var = $_.Split('='); Set-Item \"Env:$($var[0])\" $var[1] }"

		fmt.Printf("Run `%s` to set environment variables in any posix shell\n", ui.GreenStyle.Render(command1))
		fmt.Printf("Run `%s` to set environment variables in PowerShell\n", ui.GreenStyle.Render(command2))
	},
}

func init() {
	profileCmd.AddCommand(switchCmd)

	// Here you will define your flags and configuration settings.

	// Cobra supports Persistent Flags which will work for this command
	// and all subcommands, e.g.:
	// switchCmd.PersistentFlags().String("foo", "", "A help for foo")

	// Cobra supports local flags which will only run when this command
	// is called directly, e.g.:
	// switchCmd.Flags().BoolP("toggle", "t", false, "Help message for toggle")
}
