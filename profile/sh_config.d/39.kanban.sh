# -*- sh -*-
# shellcheck shell=bash
# Config snippet to configure kanban - git-centric backlog management tool

KANBAN_BIN_DIR="${HOME}/src/vegvesen/ip-2.0/tools/kanban/target/debug"

if ! envstatus_tool_disabled "kanban"; then
    if [ -d "${KANBAN_BIN_DIR}" ]; then
        export PATH="${KANBAN_BIN_DIR}:${PATH}"
    fi

    if command -v kanban >/dev/null 2>&1; then
        eval "$(kanban completion zsh 2>/dev/null)"
    else
        status_warn "kanban" "not found; build with: cd ~/src/vegvesen/ip-2.0/tools/kanban && cargo build"
    fi
fi
