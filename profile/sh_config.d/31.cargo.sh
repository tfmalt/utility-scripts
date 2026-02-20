# -*- sh -*-
# shellcheck shell=bash
# Config snippet to enable cargo/rust
# @author Thomas Malt
#

CARGO="$HOME/.cargo/bin"

if [ -d "$CARGO" ]; then
  status_ok "cargo" "found; adding $CARGO to PATH"
  export PATH="$PATH:$CARGO"
else
  status_err "cargo" "not found; setup skipped"
fi 

