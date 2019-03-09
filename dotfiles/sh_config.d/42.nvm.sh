# -*- sh -*-
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#

case $(setuptype) in
  macbook)
    export NVM_DIR="$HOME/.nvm"
    ;;
  linux-rpi|root)
    export NVM_DIR="/usr/local/nvm"
    ;;
esac

if [ -e $NVM_DIR/nvm.sh ]; then
  [ -t 0 ] && echo -e "$ICON_OK Found $NVM_DIR. Running nvm setup."
  source $NVM_DIR/nvm.sh
else
  [ -t 0 ] && echo -e "$ICON_ERR nvm Not Found. Skipping."
fi
