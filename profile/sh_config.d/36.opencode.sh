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
                status_info "opencode" "added $dir to PATH"
                ;;
        esac
    fi
}

prepend_path_if_dir "$HOME/.opencode/bin"
prepend_path_if_dir "$HOME/.local/bin"
prepend_path_if_dir "$HOME/bin"
export PATH

if command -v opencode >/dev/null 2>&1; then
    status_ok "opencode" "found; setting up completion"

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
else
    if [ -t 0 ]; then
        status_info "opencode" "not found; install with one of:"
        printf '  - brew install anomalyco/tap/opencode (recommended on macOS/Linux)\n'
        printf '  - curl -fsSL https://opencode.ai/install | bash\n'
    fi
fi
