# -*- sh -*-
# shellcheck shell=bash
# Check that awesome-vim-colorschemes is cloned and vim/colors is linked correctly

_COLORSCHEME_DIR="${PROFILE_DIR:-${PROFILE:-${DOTFILES:-}}}/vim/awesome-vim-colorschemes"
_COLORSCHEME_LINK="${PROFILE_DIR:-${PROFILE:-${DOTFILES:-}}}/vim/colors"

# Verify the repo is a valid, non-empty git clone with actual colorscheme files
if [ -L "$_COLORSCHEME_DIR" ] && [ ! -e "$_COLORSCHEME_DIR" ]; then
    status_err "vim-colors" "awesome-vim-colorschemes is a stale symlink; run install.sh to fix"
elif [ ! -d "$_COLORSCHEME_DIR/.git" ]; then
    status_err "vim-colors" "awesome-vim-colorschemes missing or not a git repo; run install.sh to clone it"
elif [ -z "$(ls -A "$_COLORSCHEME_DIR/colors" 2>/dev/null)" ]; then
    status_err "vim-colors" "awesome-vim-colorschemes/colors is empty; try: git submodule update --init"
else
    # Verify vim/colors link: stale, missing, or wrong target
    if [ -L "$_COLORSCHEME_LINK" ] && [ ! -e "$_COLORSCHEME_LINK" ]; then
        status_err "vim-colors" "vim/colors is a stale symlink; run install.sh to fix"
    elif [ ! -e "$_COLORSCHEME_LINK" ]; then
        status_err "vim-colors" "vim/colors missing; run install.sh to link it"
    elif [ -L "$_COLORSCHEME_LINK" ] && [ "$(readlink "$_COLORSCHEME_LINK")" != "$_COLORSCHEME_DIR/colors" ]; then
        status_err "vim-colors" "vim/colors points to wrong target: $(readlink "$_COLORSCHEME_LINK")"
    else
        : # colorschemes present and linked
    fi
fi

unset _COLORSCHEME_DIR _COLORSCHEME_LINK
