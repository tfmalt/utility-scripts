# -*- sh -*-
# Config snippet to configure mise (runtime version manager)
# @author Thomas Malt
#

MISE_DATA_DIR="${MISE_DATA_DIR:-$HOME/.local/share/mise}"

if command -v mise &> /dev/null; then
  [ -t 0 ] && echo -e "$ICON_OK Found mise. Activating."
  eval "$(mise activate zsh)"
elif [ -d "$MISE_DATA_DIR" ]; then
  if [ -d "$MISE_DATA_DIR/shims" ]; then
    [ -t 0 ] && echo -e "$ICON_OK Found $MISE_DATA_DIR/shims. Adding to path."
    export PATH="$MISE_DATA_DIR/shims:$PATH"
  else
    [ -t 0 ] && echo -e "$ICON_ERR mise data dir found but shims missing. Skipping."
  fi
else
  [ -t 0 ] && echo -e "$ICON_ERR mise Not Found. Skipping."
fi
