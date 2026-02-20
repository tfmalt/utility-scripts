# -*- sh -*-
# shellcheck shell=bash
# Various helpers to pimp my sh
# @author Thomas Malt
#

# Colors
COL_GREEN="\e[32m"
COL_GREEN2="\e[38;05;34m"
COL_YELLOW="\e[38;05;220m"
COL_BG_BLUE="\e[48;05;33m"
COL_RED="\e[38;05;160m"
COL_STOP="\e[0m"

# Icons
ICON_OK="$COL_GREEN2  ✔$COL_STOP"
ICON_ERR="$COL_RED  ✘$COL_STOP"
ICON_INFO="$COL_BG_BLUE  i $COL_STOP"
ICON_WARN="$COL_YELLOW  ! $COL_STOP"

status_emit() {
    local level="$1"
    local module="$2"
    local message="$3"
    local icon=""

    [ -t 0 ] || return 0

    case "$level" in
        ok)
            icon="$ICON_OK"
            ;;
        info)
            icon="$ICON_INFO"
            ;;
        warn)
            icon="$ICON_WARN"
            ;;
        err)
            icon="$ICON_ERR"
            ;;
        *)
            icon="$ICON_INFO"
            ;;
    esac

    printf '%b [%s] %s%b\n' "$icon" "$module" "$message" "$COL_STOP"
}

status_ok() {
    status_emit "ok" "$1" "$2"
}

status_info() {
    status_emit "info" "$1" "$2"
}

status_warn() {
    status_emit "warn" "$1" "$2"
}

status_err() {
    status_emit "err" "$1" "$2"
}

# delay to set vim mode
KEYTIMEOUT=1
export KEYTIMEOUT ICON_OK ICON_ERR ICON_INFO ICON_WARN
