#!/usr/bin/env zsh

source ${0:A:h}/src/_profile.zsh
source ${0:A:h}/src/_utils.zsh

function awsm() {
  gum style --foreground 150 --bold "AWS CLI Manager"
  echo "\r"

  if [ $# -eq 0 ]; then
    cmd=$(gum choose profile region logs doctor --header "Select command:")
    case $cmd in
    profile) action=$(gum choose switch get list login logout --header "Select profile action:") ;;
    region) action=$(gum choose get list clear --header "Select region action:") ;;
    logs | doctor) action="" ;;
    *)
      _error_style "Unknown command: $cmd"
      return 1
      ;;
    esac
  else
    cmd="$1"
    action="$2"
  fi

  case "${cmd}_${action}" in
  profile_switch) _profile_switch ;;
  profile_get) _profile_get ;;
  profile_list) _profile_list ;;
  profile_login) _profile_login ;;
  profile_logout) _profile_logout ;;
  region_get) echo "Running region get" ;;
  region_list) echo "Running region list" ;;
  region_clear) echo "Running region clear" ;;
  logs_) echo "Running logs" ;;
  doctor_) echo "Running doctor" ;;
  *)
    _error_style "Unknown command or action: $cmd $action"
    return 1
    ;;
  esac
}
