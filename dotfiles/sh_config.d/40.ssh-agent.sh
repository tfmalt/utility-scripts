# -*- sh -*-
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
  [ -t 0 ] && echo -ne "$ICON_INFO Initialising new SSH agent... "
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"${SSH_ENV}"
  [ -t 0 ] && echo -e "$ICON_OK succeeded"
  chmod 600 "${SSH_ENV}"
  source "${SSH_ENV}" >/dev/null

  case $(setuptype) in
  macbook)
    ssh-add -A 2>/dev/null
    [ -t 0 ] && echo -e "$ICON_INFO Adding ssh identities found in keychain to ssh-agent."
    ;;
  windows)
    [ -t 0 ] && echo -e "$ICON_INFO Adding ssh identities to ssh-agent: "
    ssh-add
    ;;
  linux-rpi | root) ;;

  esac
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
  source "${SSH_ENV}" >/dev/null
  if [[ $(ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$) ]]; then
    [ -t 0 ] && echo -e "$ICON_INFO ssh-agent aleady running ($SSH_AGENT_PID)"
  else
    start_agent
  fi
else
  start_agent
fi
