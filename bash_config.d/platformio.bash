# -*- sh -*-
# Config snippet to enable platformio
# @author Thomas Malt
#

case $(setuptype) in
    laptop)
        PIOPATH=$HOME/.platformio/penv/bin
        if [ -d $PIOPATH ]; then
            if [ -t 0 ]; then
                echo " - platformio found. Adding to path."
            fi
            PATH="$PATH:$PIOPATH"
        fi
    ;;
esac
export PATH

