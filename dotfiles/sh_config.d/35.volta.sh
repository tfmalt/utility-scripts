# -*- sh -*-
# shellcheck shell=bash
# Config snippet to configure volta
# @author Thomas Malt
#

VOLTA_HOME="$HOME/.volta"

if [ -d "$VOLTA_HOME/bin" ]; then
  [ -t 0 ] && echo -e "$ICON_OK Found $VOLTA_HOME/bin. Adding to path."
  export PATH="$VOLTA_HOME/bin:$PATH"
else
  [ -t 0 ] && echo -e "$ICON_ERR $VOLTA_HOME Not Found. Skipping."
fi 

