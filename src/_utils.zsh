function _success_style() {
  echo "$(gum style --foreground 150 "\u2714 ")$*"
}

function _error_style() {
  echo "$(gum style --foreground 1 "\u2716 ")$*"
}

function _list_style() {
  echo "$(gum style --foreground 150 "\u2192 ")$*"
}

function _header_style() {
  echo "$(gum style --foreground 4 --bold "$*")\n"
}
