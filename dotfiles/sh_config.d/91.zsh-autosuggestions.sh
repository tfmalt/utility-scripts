# -*- sh -*-
# Tweak zsh-autosuggestions behavior and style

if [ -n "$ZSH_VERSION" ]; then
  # Prefer history, fall back to completion
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  # Subtle grey suggestions
  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
fi
