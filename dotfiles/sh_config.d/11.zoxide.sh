# -*- sh -*-
# shellcheck shell=bash
# Initialize zoxide if installed

if [ -n "$ZSH_VERSION" ] && command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi
