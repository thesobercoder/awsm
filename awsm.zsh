#!/usr/bin/env zsh

source ${0:A:h}/src/_profile.zsh
source ${0:A:h}/src/_utils.zsh

function awsm() {
  gum style --foreground 2 --bold "AWS CLI Manager"
  echo "\r"

  # gum style \
  #   --foreground 2 --border-foreground 205 --border rounded --bold \
  #   --align center --margin "1 2" --padding "2 4" ""

  cmd=$(gum choose profile region logs doctor --header "Select command:")

  case $cmd in
  "profile")
    action=$(gum choose switch get list login logout --header "Select action:")
    case $action in
    "switch")
      _profile_switch
      ;;
    "get")
      _profile_get
      ;;
    "list")
      echo "Running list"
      ;;
    "login")
      _profile_login
      ;;
    "logout")
      _profile_logout
      ;;
    *)
      echo "Unknown action $action"
      ;;
    esac
    ;;
  "region")
    action=$(gum choose get list clear --header "Select action:")
    echo "Running profile $action"
    ;;
  "logs")
    echo "Running logs"
    ;;
  "doctor")
    echo "Running doctor"
    ;;
  *)
    echo "Unknown command $cmd"
    ;;
  esac
}
