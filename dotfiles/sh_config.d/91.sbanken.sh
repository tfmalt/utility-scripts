# -*- sh -*-
# shellcheck shell=bash
# Config snippet to read in credentials
# @author Thomas Malt
#

if [ -f "$HOME/.sbanken" ]; then
  source "$HOME/.sbanken"
else 
  [ -t 0 ] && echo -e "$ICON_ERR Sbanken config Not Found. Skipping."
fi
