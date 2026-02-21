# -*- sh -*-
# shellcheck shell=bash
# Ensure zsh-completions is in fpath before Oh My Zsh initializes compinit

if [ -n "$ZSH_VERSION" ]; then
  if ! envstatus_tool_disabled "homebrew" && command -v brew >/dev/null 2>&1; then
    ZC_DIR="$(brew --prefix)/share/zsh-completions"
    if [ -d "$ZC_DIR" ]; then
      fpath=("$ZC_DIR" $fpath)
    fi
    autoload -Uz compinit
    compinit
  fi
fi
