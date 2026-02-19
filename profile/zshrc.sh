# -*- sh -*-
# shellcheck shell=bash
# zshrc to tweak my zsh setup
# @author Thomas Malt
#

zmodload zsh/zprof
# autoload -U compinit
# compinit -i

PROFILE_DIR="${PROFILE:-${DOTFILES:-}}"


# First include all functions
if [ -d "$PROFILE_DIR/sh_functions.d" ]; then
  for FILE in "$PROFILE_DIR"/sh_functions.d/*sh; do
    source "$FILE"
  done
fi

# Then include configuration snippets
if [ -d "$PROFILE_DIR/sh_config.d" ]; then
  for FILE in "$PROFILE_DIR"/sh_config.d/*sh; do
    source "$FILE"
  done
fi
