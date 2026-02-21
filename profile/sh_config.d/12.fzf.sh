# -*- sh -*-
# shellcheck shell=bash
# Load fzf completion and key-bindings when installed via Homebrew

if [ -n "$ZSH_VERSION" ]; then
  if ! envstatus_tool_disabled "homebrew" && command -v brew >/dev/null 2>&1; then
    FZF_BASE="$(brew --prefix)/opt/fzf"
    [ -f "$FZF_BASE/shell/completion.zsh" ] && source "$FZF_BASE/shell/completion.zsh"
    [ -f "$FZF_BASE/shell/key-bindings.zsh" ] && source "$FZF_BASE/shell/key-bindings.zsh"
  fi
fi
