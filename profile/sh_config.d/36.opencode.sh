# -*- sh -*-
# shellcheck shell=bash
# Config snippet to configure OpenCode CLI and completions

prepend_path_if_dir() {
    local dir="$1"

    if [ -d "$dir" ]; then
        case ":$PATH:" in
            *":$dir:"*) ;;
            *)
                PATH="$dir:$PATH"
                ;;
        esac
    fi
}

prepend_path_if_dir "$HOME/.opencode/bin"
prepend_path_if_dir "$HOME/.local/bin"
prepend_path_if_dir "$HOME/bin"
if [ "$(uname -s)" = "Linux" ]; then
    if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
        prepend_path_if_dir "/home/linuxbrew/.linuxbrew/bin"
    elif command -v brew >/dev/null 2>&1; then
        prepend_path_if_dir "$(brew --prefix)/bin"
    fi
fi

export PATH

if command -v opencode >/dev/null 2>&1; then
    if [ -n "${ZSH_VERSION:-}" ]; then
        if ! type bashcompinit >/dev/null 2>&1; then
            autoload -U bashcompinit
        fi

        bashcompinit >/dev/null 2>&1
        # shellcheck disable=SC1090
        source <(opencode completion 2>/dev/null)
    elif [ -n "${BASH_VERSION:-}" ]; then
        # shellcheck disable=SC1090
        source <(opencode completion 2>/dev/null)
    else
        status_err "opencode" "unknown shell; completion setup skipped"
    fi
fi
