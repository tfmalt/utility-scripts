# -*- sh -*-
# shellcheck shell=bash
# Initialize fzf after completion setup without relying on Oh My Zsh.

if [ -n "${ZSH_VERSION:-}" ] && command -v fzf >/dev/null 2>&1; then
    if fzf --zsh >/dev/null 2>&1; then
        eval "$(fzf --zsh)"
    elif [ -r /usr/share/doc/fzf/examples/completion.zsh ] \
        && [ -r /usr/share/doc/fzf/examples/key-bindings.zsh ]; then
        source /usr/share/doc/fzf/examples/completion.zsh
        source /usr/share/doc/fzf/examples/key-bindings.zsh
    elif ! envstatus_tool_disabled "homebrew" && command -v brew >/dev/null 2>&1; then
        FZF_BASE="$(brew --prefix)/opt/fzf"
        [ -r "$FZF_BASE/shell/completion.zsh" ] && source "$FZF_BASE/shell/completion.zsh"
        [ -r "$FZF_BASE/shell/key-bindings.zsh" ] && source "$FZF_BASE/shell/key-bindings.zsh"
        unset FZF_BASE
    fi

    if [ -z "${FZF_DEFAULT_COMMAND:-}" ]; then
        if command -v fd >/dev/null 2>&1; then
            export FZF_DEFAULT_COMMAND='fd --type f --hidden --exclude .git'
        elif command -v rg >/dev/null 2>&1; then
            export FZF_DEFAULT_COMMAND='rg --files --hidden --glob "!.git/*"'
        elif command -v ag >/dev/null 2>&1; then
            export FZF_DEFAULT_COMMAND='ag -l --hidden -g "" --ignore .git'
        fi
    fi
fi
