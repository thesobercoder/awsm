function _success_style() {
  echo "$(gum style --foreground 2 "✔ ") $*"
}

function _error_style() {
  echo "$(gum style --foreground 1 "✖ ") $*"
}
