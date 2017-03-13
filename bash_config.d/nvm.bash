# -*- sh -*-
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#

case $(setuptype) in
  laptop)
    export NVM_DIR="$HOME/.nvm"
    echo " - Running nvm setup: $NVM_DIR"
    ;;
  linux-rpi|root)
    export NVM_DIR="/usr/local/nvm"
    echo " - Running nvm setup: $NVM_DIR"
    ;;
esac

