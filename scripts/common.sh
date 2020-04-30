
function prompt {
  read -r -p "$1 " "$2"
}

BOLD="$(tput bold)"
NORMAL="$(tput sgr0)"

function message {
  echo ''
  echo "$BOLD> $*$NORMAL"
}

function exec_command {
  message "[Executing] $*"
  eval "$*"
}

function confirm_command {
  prompt "OK to run '$*'? [y/N]" confirm
  if [[ ! ${confirm:-n} == 'y' ]]; then
    message "[Skipped] $*"
    return 1
  fi
  exec_command "$*"
}

function set_variable {
  local varname=$1
  shift
  if [ -z "${!varname}" ]; then
    eval "$varname=\"$@\""
  else
    echo "Error: $varname already set"
    usage
  fi
}