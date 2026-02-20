# -*- sh -*-
# shellcheck shell=bash
# Config snippet to enable platformio
# @author Thomas Malt
#

case $(setuptype) in
    macbook)
        PIOPATH="$HOME/.platformio/penv/bin"
    ;;
    windows)
        PIOPATH="/mnt/c/Users/thoma/.platformio/penv/Scripts"
        alias pio='pio.exe'
        alias platformio='platformio.exe'
    ;;
esac

if [[ -n "$PIOPATH" ]] && [ -d "$PIOPATH" ]; then
    status_ok "platformio" "found; adding $PIOPATH to PATH"
    PATH="$PATH:$PIOPATH"
    export PATH
else 
    status_err "platformio" "not found; setup skipped"
fi
