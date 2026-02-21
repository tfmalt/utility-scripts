# -*- sh -*-
# shellcheck shell=bash
# Config snippet to verify GitHub CLI is available.

if ! envstatus_tool_disabled "gh"; then
    if ! command -v gh >/dev/null 2>&1; then
        case "$(setuptype)" in
            macbook)
                status_warn "gh" "not found; install with: brew install gh"
                ;;
            windows)
                status_warn "gh" "not found; install with: winget install --id GitHub.cli"
                ;;
            *)
                status_warn "gh" "not found; install with: brew install gh or apt install gh"
                ;;
        esac
    fi
fi
