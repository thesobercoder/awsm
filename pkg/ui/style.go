package ui

import "github.com/charmbracelet/lipgloss"

var ErrorStyle = lipgloss.NewStyle().
	Bold(true).
	Foreground(lipgloss.Color("1")).
	Transform(func(s string) string {
		return "✘ " + s
	})

var SuccessStyle = lipgloss.NewStyle().
	Bold(true).
	Foreground(lipgloss.Color("2")).
	Transform(func(s string) string {
		return "✔ " + s
	})
