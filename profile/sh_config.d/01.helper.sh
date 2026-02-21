# -*- sh -*-
# shellcheck shell=bash
# Various helpers to pimp my sh
# @author Thomas Malt
#

# Colors
COL_GREEN="\e[32m"
COL_GREEN2="\e[38;05;41m"
COL_YELLOW="\e[38;05;214m"
COL_BLUE_LIGHT="\e[38;05;117m"
COL_RED="\e[38;05;167m"
COL_STOP="\e[0m"
COL_DIM="\e[38;05;240m"
COL_BOLD="\e[1m"

# Icons — Nerd Font filled circles (Font Awesome \uf0xx, requires Nerd Font)
ICON_OK="$COL_GREEN2\uf058$COL_STOP"    # nf-fa-check_circle
ICON_ERR="$COL_RED\uf057$COL_STOP"      # nf-fa-times_circle
ICON_WARN="$COL_YELLOW\uf06a$COL_STOP"  # nf-fa-exclamation_circle
ICON_INFO="$COL_BLUE_LIGHT\uf05a$COL_STOP" # nf-fa-info_circle

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

envstatus_config_file() {
    printf '%s' "${XDG_CONFIG_HOME:-$HOME/.config}/envstatus/disabled-tools.conf"
}

envstatus_tool_disabled() {
    local tool="$1"
    local config_file

    [ -n "$tool" ] || return 1
    config_file="$(envstatus_config_file)"
    [ -f "$config_file" ] || return 1

    grep -Fqx -- "$tool" "$config_file"
}

# delay to set vim mode
KEYTIMEOUT=1
export KEYTIMEOUT ICON_OK ICON_ERR ICON_INFO ICON_WARN COL_DIM COL_BOLD
