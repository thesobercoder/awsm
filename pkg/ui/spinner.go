package ui

import (
	"fmt"

	"github.com/charmbracelet/bubbles/spinner"
	tea "github.com/charmbracelet/bubbletea"
	"github.com/charmbracelet/lipgloss"
)

type spinnerModel struct {
	spinner spinner.Model
	done    bool
	err     error
	task    func() ([]string, error)
	results []string
}

type taskResultMsg struct {
	results []string
	err     error
}

func NewSpinner(task func() ([]string, error)) {
	s := spinner.New()
	s.Spinner = spinner.Dot
	s.Style = lipgloss.NewStyle().Foreground(lipgloss.Color("205"))
	model := spinnerModel{
		spinner: s,
		task:    task,
	}

	p := tea.NewProgram(model)
	m, err := p.Run()
	if err != nil {
		fmt.Println(ErrorStyle.Render(err.Error()))
		return
	}

	if m.(spinnerModel).err != nil {
		fmt.Println(ErrorStyle.Render(m.(spinnerModel).err.Error()))
		return
	}

	for _, msg := range m.(spinnerModel).results {
		fmt.Println(msg)
	}
}

func (m spinnerModel) Init() tea.Cmd {
	return tea.Batch(m.spinner.Tick, m.runTask())
}

func (m spinnerModel) Update(msg tea.Msg) (tea.Model, tea.Cmd) {
	switch msg := msg.(type) {
	case spinner.TickMsg:
		var cmd tea.Cmd
		m.spinner, cmd = m.spinner.Update(msg)
		if m.done {
			return m, tea.Quit
		}
		return m, cmd
	case taskResultMsg:
		if msg.err != nil {
			m.err = msg.err
		} else {
			m.results = msg.results
		}
		m.done = true
		return m, tea.Quit
	default:
		return m, nil
	}
}

func (m spinnerModel) View() string {
	if m.done {
		return ""
	}
	return fmt.Sprintf("%s Loading\n", m.spinner.View())
}

func (m spinnerModel) runTask() tea.Cmd {
	return func() tea.Msg {
		results, err := m.task()
		return taskResultMsg{results, err}
	}
}
