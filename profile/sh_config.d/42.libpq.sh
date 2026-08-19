# -*- sh -*-
# shellcheck shell=bash
# Add Homebrew's libpq client tools to PATH when available.

if ! envstatus_tool_disabled "homebrew" && command -v brew >/dev/null 2>&1; then
    LIBPQ_BIN="$(brew --prefix libpq 2>/dev/null)/bin"
    prepend_path_if_dir "$LIBPQ_BIN"
fi

export PATH
