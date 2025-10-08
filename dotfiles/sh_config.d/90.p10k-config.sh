# -*- sh -*-
# Load user powerlevel10k configuration late so it overrides earlier defaults
# Only for zsh sessions

if [ -n "$ZSH_VERSION" ]; then
  if [ -r "$DOTFILES/p10k.zsh" ]; then
    # shellcheck disable=SC1090
    . "$DOTFILES/p10k.zsh"
  fi
fi
