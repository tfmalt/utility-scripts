# -*- sh -*-
# zshrc to tweak my zsh setup
# @author Thomas Malt
#

# echo "Running tmsh zshrc setup"

if [ -d $TMSH/bash_functions.d ]; then
  for FILE in $TMSH/bash_functions.d/*sh; do
    source $FILE
  done
fi

if [ -d $TMSH/bash_config.d ]; then
  for FILE in $TMSH/bash_config.d/*sh; do
    source $FILE
  done
fi

