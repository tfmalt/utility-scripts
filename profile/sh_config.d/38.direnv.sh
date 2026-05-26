# -*- sh -*-
# Config snippet to configure direnv (directory-scoped environment variables)
# @author Thomas Malt
#

if ! envstatus_tool_disabled "direnv"; then
  if command -v direnv &> /dev/null; then
    eval "$(direnv hook zsh)"
  else
    status_err "direnv" "not found; setup skipped"
  fi
fi
