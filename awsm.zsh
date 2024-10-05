#!/usr/bin/env zsh

# Copyright © 2024 Soham Dasgupta soham@thesobercoder.com

# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:

# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

source ${0:A:h}/src/_profile.zsh
source ${0:A:h}/src/_region.zsh
source ${0:A:h}/src/_utils.zsh

function awsm() {
  echo "\r"

  if [ $# -eq 0 ]; then
    cmd=$(gum choose profile region logs doctor --header "Select command:")
    case $cmd in
    profile) action=$(gum choose switch login logout get list --header "Select action:") ;;
    region) action=$(gum choose get set clear --header "Select action:") ;;
    help | doctor) action="" ;;
    *)
      _error_style "Unknown command: $cmd"
      return 1
      ;;
    esac
  else
    cmd="$1"
    shift
    action="$1"
    case "${cmd}_${action}" in
    profile_switch | profile_login | region_set)
      shift
      ;;
    esac
  fi

  case "${cmd}_${action}" in
  profile_switch) _profile_switch "$@" ;;
  profile_get) _profile_get ;;
  profile_list) _profile_list ;;
  profile_login) _profile_login "$@" ;;
  profile_logout) _profile_logout ;;
  region_get) _region_get ;;
  region_set) _region_set "$@" ;;
  region_clear) _region_clear ;;
  doctor_) echo "Running doctor" ;;
  help_) _show_help ;;
  *)
    _error_style "Unknown command or action: $cmd $action"
    return 1
    ;;
  esac
}

function _show_help() {
  _header_style "AWS CLI Manager - Help"
  echo "Usage: awsm <command> <action> [options]"
  echo
  _header_style "Commands and Actions:"
  echo "  profile switch [-p profile] : Switches AWS profile. Interactive if -p is not specified."
  echo "  profile get                 : Displays the current AWS profile identity."
  echo "  profile list                : Lists available AWS profiles."
  echo "  profile login [-p profile]  : Logs into AWS SSO profile. Interactive if -p is not specified."
  echo "  profile logout              : Logs out of AWS SSO."
  echo "  region get                  : Displays the current AWS region."
  echo "  region set [-r region]      : Sets the AWS region. Interactive if -s is not specified."
  echo "  region clear                : Clears the current AWS region setting."
  echo "  doctor                      : Runs diagnostics."
  echo "  help                        : Displays this help message."

  echo
  _header_style "Options:"
  echo "  -p <profile>                : Specify the AWS profile for profile-related commands."
  echo "  -r <region>                 : Specify the AWS region for region-related commands."
}

function _awsm() {
  local -a commands actions options
  local state

  _arguments -C \
    '1: :->command' \
    '2: :->action' \
    '*: :->args'

  case $state in
  command)
    commands=(
      'profile:Manage AWS profiles'
      'region:Manage AWS regions'
      'doctor:Run diagnostics'
      'help:Display help message'
    )
    _describe -t commands 'awsm commands' commands
    ;;
  action)
    case $words[2] in
    profile)
      actions=(
        'switch:Switch AWS profile'
        'get:Display current AWS profile identity'
        'list:List available AWS profiles'
        'login:Log into AWS SSO profile'
        'logout:Log out of AWS SSO'
      )
      _describe -t actions 'profile actions' actions
      ;;
    region)
      actions=(
        'get:Display current AWS region'
        'set:Set AWS region'
        'clear:Clear current AWS region setting'
      )
      _describe -t actions 'region actions' actions
      ;;
    esac
    ;;
  esac
}

compdef _awsm awsm
