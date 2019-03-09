# -*- sh -*-
# Config snippet to enable platformio
# @author Thomas Malt
#

CARGO=$HOME/.cargo/bin

if [ -d $CARGO ]; then
  [ -t 0 ] && echo -e "$ICON_OK Found $CARGO. Adding to path."
  export PATH="$PATH:$CARGO"
else
  [ -t 0 ] && echo -e "$ICON_ERR Cargo Not Found. Skipping."
fi 


