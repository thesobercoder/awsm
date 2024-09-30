#!/usr/bin/env zsh

source ./src/_profile.zsh
source ./src/_utils.zsh

function awsm() {
  gum style \
    --foreground 2 --border-foreground 205 --border rounded --bold \
    --align center --margin "1 2" --padding "2 4" <<'EOF'
   _____      _      _    ______    __    __
  /\___/\    /_/\  /\_\  / ____/\  /_/\  /\_\
 / / _ \ \   ) ) )( ( (  ) ) __\/  ) ) \/ ( (
 \ \(_)/ /  /_/ //\\ \_\  \ \ \   /_/ \  / \_\
 / / _ \ \  \ \ /  \ / /  _\ \ \  \ \ \\// / /
( (_( )_) )  )_) /\ (_(  )____) )  )_) )( (_(
 \/_/ \_\/   \_\/  \/_/  \____\/   \_\/  \/_/

AWS CLI Manager
@thesobercoder
EOF

  cmd=$(gum choose profile region logs doctor --header "Select command:")

  case $cmd in
  "profile")
    action=$(gum choose switch get list login logout --header "Select action:")
    case $action in
    "switch")
      _switch_profile
      ;;
    "get")
      echo "Running get"
      ;;
    "list")
      echo "Running list"
      ;;
    "login")
      echo "Running login"
      ;;
    "logout")
      echo "Running logout"
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
