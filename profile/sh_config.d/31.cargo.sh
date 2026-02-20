# -*- sh -*-
# shellcheck shell=bash
# Config snippet to enable cargo/rust
# @author Thomas Malt
#

CARGO="$HOME/.cargo/bin"

if [ -d "$CARGO" ]; then
  export PATH="$PATH:$CARGO"
else
  status_err "cargo" "not found; setup skipped"
fi 

