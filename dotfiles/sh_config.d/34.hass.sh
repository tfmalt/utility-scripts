# -*- sh -*-
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#

if [[ -d $HOME/.local/bin ]]; then
    PATH="$PATH:$HOME/.local/bin"
fi
export PATH

if [[ -x $HOME/.local/bin/hass-cli ]]; then
  alias hass=hass-cli
  export HASS_SERVER="http://192.168.71.3:8123"
  export HASS_TOKEN="eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJjZTRiYzIzM2I4ZjA0NjI0YmY0M2JhNmY4YTBlMzQ0NSIsImlhdCI6MTU5MTEzNjA2MSwiZXhwIjoxOTA2NDk2MDYxfQ.hXH3xdK3N2plRxPTqyXdSILlSXZn2BbSBkCm0G8-Lws"

  # source <($HOME/.local/bin/hass-cli completion zsh)

  [ -t 0 ] && echo -e "$ICON_OK Found hass-cli. Setting up."
fi
