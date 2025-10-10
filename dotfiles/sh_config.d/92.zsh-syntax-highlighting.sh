# -*- sh -*-
# Source zsh-syntax-highlighting

if [ -n "$ZSH_VERSION" ]; then
  # Source system-wide plugin if available
  if [[ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]]; then
    source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
  fi
fi
