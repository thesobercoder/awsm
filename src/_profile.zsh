function _profile_select() {
  unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_EB_PROFILE AWS_ACCOUNT AWS_PROFILE_REGION AWS_REGION AWS_DEFAULT_REGION
  local profile=$(gum choose $(gum spin --spinner dot --title "Fetching profiles" --show-output -- aws --no-cli-pager configure list-profiles | tr "[:space:]" "\n") --header "Choose profile:")
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
  local profile=$(_profile_select)
  if [[ $? -ne 0 ]]; then
    _error_style "No profile selected"
    return 1
  fi
  _profile_update $profile
  _success_style "Switched to profile $profile"
}

function _profile_login() {
  local profile=$(_profile_select)
  if [[ $? -ne 0 ]]; then
    _error_style "No profile selected"
    return 1
  fi
  local output=$(gum spin --spinner dot --title "Logging in" --show-output -- aws sso login --profile $profile >/dev/null)
  if [[ $? -ne 0 ]]; then
    _error_style "$?"
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
  while read -r line; do
    _success_style $line
  done <<<"$result"
}

function _profile_logout() {
  gum spin --spinner dot --title "Logging out" --show-output -- aws sso logout
  if [[ $? -ne 0 ]]; then
    _error_style "$?"
    return $?
  fi
  unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_EB_PROFILE AWS_ACCOUNT AWS_PROFILE_REGION AWS_REGION AWS_DEFAULT_REGION
  _success_style "Successfully logged out"
}
