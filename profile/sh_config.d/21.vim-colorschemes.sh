# -*- sh -*-
# shellcheck shell=bash
# Check that awesome-vim-colorschemes is cloned and vim/colors is linked correctly

_COLORSCHEME_DIR="${PROFILE_DIR:-${PROFILE:-}}/vim/awesome-vim-colorschemes"
_COLORSCHEME_LINK="${PROFILE_DIR:-${PROFILE:-}}/vim/colors"

_resolve_path() {
    realpath "$1" 2>/dev/null || readlink -f "$1" 2>/dev/null || printf '%s' "$1"
}

# Verify the repo is a valid, non-empty git clone with actual colorscheme files
if envstatus_tool_disabled "vim-colors"; then
    :
elif [ -L "$_COLORSCHEME_DIR" ] && [ ! -e "$_COLORSCHEME_DIR" ]; then
    status_err "vim-colors" "awesome-vim-colorschemes is a stale symlink; run install.sh to fix"
elif [ ! -d "$_COLORSCHEME_DIR/.git" ]; then
    status_err "vim-colors" "awesome-vim-colorschemes missing or not a git repo; run install.sh to clone it"
elif [ -z "$(ls -A "$_COLORSCHEME_DIR/colors" 2>/dev/null)" ]; then
    status_err "vim-colors" "awesome-vim-colorschemes/colors is empty; try: git submodule update --init"
else
    _EXPECTED_TARGET="$(_resolve_path "$_COLORSCHEME_DIR/colors")"

    # Verify vim/colors link: stale, missing, or wrong target
    if [ -L "$_COLORSCHEME_LINK" ] && [ ! -e "$_COLORSCHEME_LINK" ]; then
        status_err "vim-colors" "vim/colors is a stale symlink; run install.sh to fix"
    elif [ ! -e "$_COLORSCHEME_LINK" ]; then
        status_err "vim-colors" "vim/colors missing; run install.sh to link it"
    elif [ -L "$_COLORSCHEME_LINK" ]; then
        _RAW_TARGET="$(readlink "$_COLORSCHEME_LINK")"
        case "$_RAW_TARGET" in
            /*) _RESOLVED_TARGET_INPUT="$_RAW_TARGET" ;;
            *)
                _RESOLVED_TARGET_INPUT="$(dirname "$_COLORSCHEME_LINK")/$_RAW_TARGET"
                ;;
        esac
        _ACTUAL_TARGET="$(_resolve_path "$_RESOLVED_TARGET_INPUT")"

        if [ "$_ACTUAL_TARGET" != "$_EXPECTED_TARGET" ]; then
            status_err "vim-colors" "vim/colors points to wrong target: $_RAW_TARGET"
        fi
    else
        : # colorschemes present and linked
    fi
fi

unset _COLORSCHEME_DIR _COLORSCHEME_LINK _EXPECTED_TARGET _RAW_TARGET _RESOLVED_TARGET_INPUT _ACTUAL_TARGET
unset -f _resolve_path
