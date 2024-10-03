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
source ${0:A:h}/src/_logs.zsh
source ${0:A:h}/src/_utils.zsh

function awsm() {
  gum style --foreground 150 --bold "AWS CLI Manager"
  echo "\r"

  if [ $# -eq 0 ]; then
    cmd=$(gum choose profile region logs doctor --header "Select command:")
    case $cmd in
    profile) action=$(gum choose switch get list login logout --header "Select action:") ;;
    region) action=$(gum choose get set clear --header "Select action:") ;;
    logs) action=$(gum choose search purge --header "Select action:") ;;
    doctor) action="" ;;
    *)
      _error_style "Unknown command: $cmd"
      return 1
      ;;
    esac
  else
    cmd="$1"
    shift
    action="$1"
    shift
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
  logs_search) _logs_search ;;
  logs_purge) _logs_purge ;;
  doctor_) echo "Running doctor" ;;
  *)
    _error_style "Unknown command or action: $cmd $action"
    return 1
    ;;
  esac
}
