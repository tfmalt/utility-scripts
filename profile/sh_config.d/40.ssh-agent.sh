# -*- sh -*-
# shellcheck shell=bash
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
  status_info "ssh-agent" "initializing new SSH agent"
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' >"${SSH_ENV}"
  status_ok "ssh-agent" "agent started"
  chmod 600 "${SSH_ENV}"
  source "${SSH_ENV}" >/dev/null

  case $(setuptype) in
  macbook)
    ssh-add -A 2>/dev/null
    status_info "ssh-agent" "adding SSH identities from keychain"
    ;;
  windows | linux-server | linux | linux-virtual)
    status_info "ssh-agent" "adding SSH identities"
    ssh-add 2>/dev/null
    ;;
  linux-rpi | root) ;;

  esac
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
  source "${SSH_ENV}" >/dev/null
  # Check if the SSH_AGENT_PID process exists and is actually ssh-agent
  if [ -n "${SSH_AGENT_PID}" ] && ps -p "${SSH_AGENT_PID}" >/dev/null 2>&1 && ps -p "${SSH_AGENT_PID}" -o comm= 2>/dev/null | grep -q '^ssh-agent$'; then
    status_info "ssh-agent" "already running (pid $SSH_AGENT_PID)"
  else
    start_agent
  fi
else
  start_agent
fi
