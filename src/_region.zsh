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

function _region_get() {
  _header_style "Current Region:"
  _success_style "AWS_REGION: $AWS_REGION"
  _success_style "AWS_DEFAULT_REGION: $AWS_DEFAULT_REGION"
}

function _region_set() {
  local region=""

  while getopts ":r:" opt; do
    case ${opt} in
    r)
      region=$OPTARG
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

  if [[ -z $region ]]; then
    region=$(gum choose --header "Choose region:" $(gum spin --spinner dot --title "Fetching regions" --show-output -- aws ec2 describe-regions --region "us-east-1" --output json | jq -r ".Regions[].RegionName" | tr "[:space:]" "\n"))
    if [[ $? -ne 0 || -z $region ]]; then
      _error_style "No region selected"
      return 1
    fi
  fi

  unset AWS_REGION AWS_DEFAULT_REGION
  export AWS_REGION=$region
  export AWS_DEFAULT_REGION=$region
}

function _region_clear() {
  unset AWS_REGION AWS_DEFAULT_REGION
}
