# -*- sh -*-
# shellcheck shell=bash
# Config snippet to enable platformio
# @author Thomas Malt
#

if ! envstatus_tool_disabled "platformio"; then
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
        PATH="$PATH:$PIOPATH"
        export PATH
    else
        status_err "platformio" "not found; setup skipped"
    fi
fi
