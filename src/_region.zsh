function _region_get() {
  _header_style "Current Region:"
  _success_style "AWS_REGION: $AWS_REGION"
  _success_style "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
}

function _region_set() {
  unset AWS_REGION AWS_DEFAULT_REGION
  local region=$(gum choose --header "Choose region:" $(gum spin --spinner dot --title "Fetching regions" --show-output -- aws ec2 describe-regions --region "us-east-1" --output json | jq -r ".Regions[].RegionName" | tr "[:space:]" "\n"))
  if [[ -z $region ]]; then
    return 1
  fi
  export AWS_REGION=$region
  export AWS_DEFAULT_REGION=$region
}

function _region_clear() {
  unset AWS_REGION AWS_DEFAULT_REGION
}
