# -*- sh -*-
# shellcheck shell=bash
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
  # Default server can be overridden with environment
  export HASS_SERVER="${HASS_SERVER:-http://192.168.71.3:8123}"
  # Expect HASS_TOKEN to be provided via environment or a secrets manager
  if [ -z "$HASS_TOKEN" ]; then
    status_info "hass" "HASS_TOKEN not set; hass-cli may prompt for authentication"
  fi
  # source <($HOME/.local/bin/hass-cli completion zsh)
  status_ok "hass" "hass-cli found; setup complete"
fi
