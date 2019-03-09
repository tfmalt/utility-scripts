# -*- sh -*-
# zshrc to tweak my zsh setup
# @author Thomas Malt
#


if [ -d $DOTFILES/sh_functions.d ]; then
  for FILE in $DOTFILES/sh_functions.d/*sh; do
    source $FILE
  done
fi

if [ -d $DOTFILES/sh_config.d ]; then
  for FILE in $DOTFILES/sh_config.d/*sh; do
    source $FILE
  done
fi

