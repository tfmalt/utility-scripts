# -*- sh -*-
# Config snippet to enable platformio
# @author Thomas Malt
#

case $(setuptype) in
    laptop)
        PIOPATH=$HOME/.platformio/penv/bin
        if [ -d $PIOPATH ]; then
            echo " - platformio found. Adding to path."
            PATH="$PATH:$PIOPATH"
        fi
    ;;
esac
export PATH

