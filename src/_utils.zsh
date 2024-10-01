function _success_style() {
  echo "$(gum style --foreground 150 "\u2714 ")$*"
}

function _error_style() {
  echo "$(gum style --foreground 160 "\u2716 ")$*"
}

function _warn_style() {
  echo "$(gum style --foreground 215 "\u26a0 ")$*"
}

function _list_style() {
  echo "$(gum style --foreground 150 "\u2192 ")$*"
}

function _header_style() {
  echo "$(gum style --foreground 4 --bold "$*")\n"
}
