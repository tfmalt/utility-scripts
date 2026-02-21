# -*- sh -*-
# shellcheck shell=bash
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"${SSH_ENV}"
  chmod 600 "${SSH_ENV}"
  source "${SSH_ENV}" >/dev/null

  case $(setuptype) in
  macbook)
    ssh-add -A 2>/dev/null
    ;;
  windows | linux-server | linux | linux-virtual)
    ssh-add 2>/dev/null
    ;;
  linux-rpi | root) ;;

  esac
}

if ! envstatus_tool_disabled "ssh-agent"; then
  _ssh_agent_comm=""
  _ssh_agent_name=""
  # Source SSH settings, if applicable
  if [ -f "${SSH_ENV}" ]; then
    source "${SSH_ENV}" >/dev/null
    # Check if the SSH_AGENT_PID process exists and is actually ssh-agent
    if [ -n "${SSH_AGENT_PID:-}" ] && ps -p "${SSH_AGENT_PID}" >/dev/null 2>&1; then
      _ssh_agent_comm=$(ps -p "${SSH_AGENT_PID}" -o comm= 2>/dev/null || true)
      _ssh_agent_name=${_ssh_agent_comm##*/}
    fi
    if [ "${_ssh_agent_name}" = "ssh-agent" ]; then
      : # already running
    else
      start_agent
    fi
  else
    start_agent
  fi
fi
