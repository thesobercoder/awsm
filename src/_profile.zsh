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

function _profile_select() {
  unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_EB_PROFILE AWS_ACCOUNT AWS_PROFILE_REGION AWS_REGION AWS_DEFAULT_REGION
  local profile=$(gum choose --header "Choose profile:" $(gum spin --spinner dot --title "Fetching profiles" --show-output -- aws --no-cli-pager configure list-profiles | tr "[:space:]" "\n"))
  if [[ -z $profile ]]; then
    return 1
  fi
  echo $profile
}

function _profile_update() {
  local profile=$1
  export AWS_PROFILE=$profile
  export AWS_DEFAULT_PROFILE=$profile
  export AWS_EB_PROFILE=$profile
  local account=$(aws configure get sso_account_id --profile "$profile" | tr -d "[:space:]")
  if [[ -n $account ]]; then
    export AWS_ACCOUNT=$account
  fi
  local region=$(aws configure get region --profile "$profile" | tr -d "[:space:]")
  if [[ -n $region ]]; then
    export AWS_PROFILE_REGION=$region
    export AWS_REGION=$region
    export AWS_DEFAULT_REGION=$region
  fi
}

function _profile_switch() {
  local profile=""

  while getopts ":p:" opt; do
    case ${opt} in
    p)
      profile=$OPTARG
      ;;
    \?)
      _error_style "Invalid option: -$OPTARG"
      return 1
      ;;
    :)
      _error_style "Option -$OPTARG requires an argument."
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [[ -z $profile ]]; then
    profile=$(_profile_select)
    if [[ $? -ne 0 || -z $profile ]]; then
      _error_style "No profile selected"
      return 1
    fi
  fi

  # Proceed with updating the profile
  _profile_update $profile
  _success_style "Switched to profile $profile"
}

function _profile_login() {
  local profile=""

  while getopts ":p:" opt; do
    case ${opt} in
    p)
      profile=$OPTARG
      ;;
    \?)
      _error_style "Invalid option: -$OPTARG"
      return 1
      ;;
    :)
      _error_style "Option -$OPTARG requires an argument."
      return 1
      ;;
    esac
  done

  shift $((OPTIND - 1))

  if [[ -z $profile ]]; then
    profile=$(_profile_select)
    if [[ $? -ne 0 || -z $profile ]]; then
      _error_style "No profile selected"
      return 1
    fi
  fi

  local output=$(gum spin --spinner dot --title "Logging in" --show-output -- aws sso login --profile $profile >/dev/null)

  if [[ $? -ne 0 ]]; then
    _error_style "$output"
    return $?
  fi

  _profile_update $profile
  _success_style "Logged into profile $profile"
}

function _profile_get() {
  result=$(gum spin --spinner dot --title "Fetching current profile" --show-output -- aws sts get-caller-identity --no-cli-pager --output json | jq -r '"UserId: \(.UserId)\nAccount: \(.Account)\nArn: \(.Arn)"')
  if [[ -z $result ]]; then
    _error_style "No active profile found"
    return 1
  fi
  _header_style "Current Profile:"
  while read -r line; do
    _list_style $line
  done <<<"$result"
}

function _profile_logout() {
  local output=$(gum spin --spinner dot --title "Logging out" --show-output -- aws sso logout >/dev/null)
  if [[ $? -ne 0 ]]; then
    _error_style "$output"
    return $?
  fi
  unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_EB_PROFILE AWS_ACCOUNT AWS_PROFILE_REGION AWS_REGION AWS_DEFAULT_REGION
  _success_style "Successfully logged out"
}

function _profile_list() {
  result=$(gum spin --spinner dot --title "Fetching profiles" --show-output -- aws configure list-profiles --no-cli-pager)
  if [[ -z $result ]]; then
    _error_style "No profiles found"
    return 1
  fi
  _header_style "Profiles:"
  while read -r line; do
    _list_style $line
  done <<<"$result"
}
