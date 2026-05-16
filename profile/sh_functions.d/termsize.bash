#
# A function for printing the current terminal size and ruler.
#
termsize() {
    local cols="${COLUMNS:-}"
    local lines="${LINES:-}"
    local stty_size=""
    local i marker
    local ruler=""

    if ! [[ "$cols" =~ ^[0-9]+$ ]] || [ "$cols" -le 0 ]; then
        cols=""
    fi
    if ! [[ "$lines" =~ ^[0-9]+$ ]] || [ "$lines" -le 0 ]; then
        lines=""
    fi

    if [ -z "$cols" ] || [ -z "$lines" ]; then
        if command -v tput >/dev/null 2>&1; then
            [ -z "$cols" ] && cols=$(tput cols 2>/dev/null || true)
            [ -z "$lines" ] && lines=$(tput lines 2>/dev/null || true)
        fi
    fi

    if [ -z "$cols" ] || [ -z "$lines" ]; then
        stty_size=$(stty size 2>/dev/null || true)
        if [[ "$stty_size" =~ ^([0-9]+)[[:space:]]+([0-9]+)$ ]]; then
            [ -z "$lines" ] && lines="${BASH_REMATCH[1]}"
            [ -z "$cols" ] && cols="${BASH_REMATCH[2]}"
        fi
    fi

    cols="${cols:-80}"
    lines="${lines:-24}"

    printf '󰍹  Size: %s x %s\n' "$cols" "$lines"

    for (( i = 1; i <= 80; i++ )); do
        if (( i == 1 || i == 80 || i % 10 == 0 )); then
            marker='|'
        elif (( i % 5 == 0 )); then
            marker='┆'
        else
            marker='─'
        fi
        ruler+="$marker"
    done

    printf '%s\n' "$ruler"
    printf '1%77s80\n' ''
}
