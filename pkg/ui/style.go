package ui

import "github.com/charmbracelet/lipgloss"

var RedStyle = lipgloss.NewStyle().
	Foreground(lipgloss.Color("1"))

var GreenStyle = lipgloss.NewStyle().
	Foreground(lipgloss.Color("2"))

var SuccessStyle = lipgloss.NewStyle().
	Transform(func(s string) string {
		return GreenStyle.Render("✔ ") + s
	})

var ErrorStyle = lipgloss.NewStyle().
	Transform(func(s string) string {
		return RedStyle.Render("✖ ") + s
	})
