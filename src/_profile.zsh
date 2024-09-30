function _switch_profile() {
  unset AWS_PROFILE AWS_DEFAULT_PROFILE AWS_EB_PROFILE AWS_ACCOUNT AWS_PROFILE_REGION AWS_REGION AWS_DEFAULT_REGION
  local profile=$(gum choose $(gum spin --spinner dot --title "Fetching profiles" -- aws --no-cli-pager configure list-profiles) --header "Choose profile:")
  if [[ -z $profile ]]; then
    return 1
  fi
  export AWS_PROFILE=$profile
  export AWS_DEFAULT_PROFILE=$profile
  export AWS_EB_PROFILE=$profile
  export AWS_ACCOUNT=$(aws configure get sso_account_id --profile "$profile" | tr -d '[:space:]')
  local region=$(aws configure get region --profile "$profile" | tr -d '[:space:]')
  if [[ -n $region ]]; then
    export AWS_PROFILE_REGION=$region
    export AWS_REGION=$region
    export AWS_DEFAULT_REGION=$region
  fi
  _success_style "Switched to profile $profile"
}
