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
    windows)
        PIOPATH=/mnt/c/Users/thoma/.platformio/penv/Scripts
        if [ -d $PIOPATH ]; then
            if [ -t 0 ]; then
                echo " - platformio found. adding to path."
            fi
            PATH="$PATH:$PIOPATH"
        fi
        alias pio='pio.exe'
        alias platformio='platformio.exe'
    ;;
esac
export PATH

