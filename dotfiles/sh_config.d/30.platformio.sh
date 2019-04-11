# -*- sh -*-
# Config snippet to enable platformio
# @author Thomas Malt
#

case $(setuptype) in
    macbook)
        PIOPATH=$HOME/.platformio/penv/bin
    ;;
    windows)
        PIOPATH=/mnt/c/Users/thoma/.platformio/penv/Scripts
        alias pio='pio.exe'
        alias platformio='platformio.exe'
    ;;
esac

if [[ $PIOPATH ]] && [ -d $PIOPATH ]; then
    [ -t 0 ] &&  echo -e "$ICON_OK Found platformio. Adding to path."
    PATH="$PATH:$PIOPATH"
    export PATH
else 
    [ -t 0 ] && echo -e "$ICON_ERR Platformio Not Found. Skipping."
fi

