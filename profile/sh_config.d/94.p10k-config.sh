# -*- sh -*-
# shellcheck shell=bash
# Load user powerlevel10k configuration late so it overrides earlier defaults
# Only for zsh sessions

if [ -n "$ZSH_VERSION" ]; then
  PROFILE_DIR="${PROFILE:-}"
  if [ -r "$PROFILE_DIR/p10k.zsh" ]; then
    # shellcheck disable=SC1090
    . "$PROFILE_DIR/p10k.zsh"
  fi
fi
