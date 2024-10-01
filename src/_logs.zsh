function _logs_search() {
  export MSYS_NO_PATHCONV=1
  local selected_group=$(gum choose --height 30 --header "Choose log group:" $(gum spin --spinner dot --title "Fetching log groups" --show-output -- aws logs describe-log-groups --query "logGroups[*].logGroupName" --no-cli-pager --output json | jq -r '.[]' | tr "[:space:]" "\n"))
  if [[ -z $selected_group ]]; then
    return 1
  fi
  local end_time=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  local start_time=$(date -u -d "1 day ago" +"%Y-%m-%dT%H:%M:%SZ")
  local search_pattern=$(gum input --prompt "Search Pattern: ")
  if [[ -z $search_pattern ]]; then
    _error_style "Search pattern must be provided"
    return 1
  fi
  local exclude_patterns=$(gum input --prompt "Exclude Patterns(comma separated): ")
  if [[ -n $exclude_patterns ]]; then
    local result=""
    echo "$exclude_patterns" | tr ',' '\n' | while IFS= read -r value; do
      trimmed_value="${value#"${value%%[! ]*}"}"
      trimmed_value="${trimmed_value%"${trimmed_value##*[! ]}"}"
      if [[ -n $result ]]; then
        result+=" && "
      fi
      result+="w1!=\"*${trimmed_value}*\""
    done
    final_string="[$result]"
  else
    final_string="%%"
  fi

  gum spin --spinner dot --title "Fetching log streams" --show-output -- aws logs filter-log-events --filter-pattern "%$search_pattern%" --log-group-name "$selected_group" --start-time "$(date -d "$start_time" +%s)000" --end-time "$(date -d "$end_time" +%s)000" --query "events[*].logStreamName" --no-cli-pager --output json | jq -r ".[]" | sort -u | while read -r log_stream; do
    log_stream="${log_stream//[[:space:]]/}"

    _success_style "Fetching logs from stream ${log_stream##*/}\n"

    aws logs filter-log-events \
      --log-group-name "$selected_group" \
      --log-stream-names "$log_stream" \
      --start-time "$(date -d "$start_time" +%s)000" \
      --end-time "$(date -d "$end_time" +%s)000" \
      --query "events[*].message" \
      --filter-pattern "$final_string" \
      --no-cli-pager \
      --output json | jq -r '.[]' | grep -v "^$"

    #
  done

  # echo $group
  unset MSYS_NO_PATHCONV
}

function _logs_purge() {
  export MSYS_NO_PATHCONV=1
  local group=$(gum choose --height 40 --header "Choose log group:" $(gum spin --spinner dot --title "Fetching log groups" --show-output -- aws logs describe-log-groups --query "logGroups[*].logGroupName" --no-cli-pager --output json | jq -r '.[]' | tr "[:space:]" "\n"))
  if [[ -z $group ]]; then
    return 1
  fi
  echo $group
  unset MSYS_NO_PATHCONV
}
