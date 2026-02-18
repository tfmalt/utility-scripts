# -*- sh -*-
# shellcheck shell=bash
# Tweak zsh-autosuggestions behavior and style

if [ -n "$ZSH_VERSION" ]; then
  # Source system-wide plugin if available
  if [[ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]]; then
    source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
  fi

  # Prefer history, fall back to completion
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  # Subtle grey suggestions
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi
