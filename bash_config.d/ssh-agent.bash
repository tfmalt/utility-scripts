# -*- sh -*-
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#
SSH_ENV="$HOME/.ssh/environment"

function start_agent {
  echo -n " - Initialising new SSH agent... "
  /usr/bin/ssh-agent | sed 's/^echo/#echo/' > "${SSH_ENV}"
  echo succeeded
  chmod 600 "${SSH_ENV}"
  source "${SSH_ENV}" > /dev/null
}

# Source SSH settings, if applicable

if [ -f "${SSH_ENV}" ]; then
  source "${SSH_ENV}" > /dev/null
  ps -ef | grep ${SSH_AGENT_PID} | grep ssh-agent$ > /dev/null || {
    start_agent;
  }
else
  start_agent;
fi

case $(setuptype) in
  laptop)
    ssh-add -A 2>/dev/null
    echo " - Adding ssh identities found in keychain to ssh-agent."
    ;;
  linux-rpi|root)
    ;;
esac

