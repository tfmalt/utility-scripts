# -*- sh -*-
# Config snippet to configure mise (runtime version manager)
# @author Thomas Malt
#

MISE_DATA_DIR="${MISE_DATA_DIR:-$HOME/.local/share/mise}"

if command -v mise &> /dev/null; then
  eval "$(mise activate zsh)"
elif [ -d "$MISE_DATA_DIR" ]; then
  if [ -d "$MISE_DATA_DIR/shims" ]; then
    export PATH="$MISE_DATA_DIR/shims:$PATH"
  else
    status_err "mise" "data directory found but shims missing; setup skipped"
  fi
else
  status_err "mise" "not found; setup skipped"
fi
