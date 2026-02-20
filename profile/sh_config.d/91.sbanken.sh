# -*- sh -*-
# shellcheck shell=bash
# Config snippet to read in credentials
# @author Thomas Malt
#

if [ -f "$HOME/.sbanken" ]; then
  source "$HOME/.sbanken"
else 
  status_err "sbanken" "config file not found; setup skipped"
fi
