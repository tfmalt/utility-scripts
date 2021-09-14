# -*- sh -*-
# zshrc to tweak my zsh setup
# @author Thomas Malt
#

zmodload zsh/zprof
# autoload -U compinit
# compinit -i


# First include all functions
if [ -d $DOTFILES/sh_functions.d ]; then
  for FILE in $DOTFILES/sh_functions.d/*sh; do
    source $FILE
  done
fi

# Then include configuration snippets
if [ -d $DOTFILES/sh_config.d ]; then
  for FILE in $DOTFILES/sh_config.d/*sh; do
    source $FILE
  done
fi

