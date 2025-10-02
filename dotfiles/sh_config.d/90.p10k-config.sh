# -*- sh -*-
# Load user powerlevel10k configuration late so it overrides earlier defaults
# Only for zsh sessions

if [ -n "$ZSH_VERSION" ]; then
  if [ -r "$HOME/.p10k.zsh" ]; then
    # shellcheck disable=SC1090
    . "$HOME/.p10k.zsh"
  fi
fi
