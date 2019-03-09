# -*- sh -*-
# Config snippet to enable platformio
# @author Thomas Malt
#

CARGO=$HOME/.cargo/bin

if [ -d $CARGO ]; then
  [ -t 0 ] && echo " - Found $CARGO. Adding to path."
  export PATH="$PATH:$CARGO"
fi 

export PATH

