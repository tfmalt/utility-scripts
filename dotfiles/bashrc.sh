# -*- sh -*-
# shellcheck shell=bash
#
# bashrc
#
# @author Thomas Malt
#

SHELL=$(which bash)
export SHELL

# setting vi mode
set -o vi

# Setting the path

[ -d "$HOME/bin" ] && PATH="$PATH:$HOME/bin"

export PATH

# Locale settings
EDITOR="vim"
RSYNC_RSH="ssh"					# We use ssh for rsync
VISUAL="$EDITOR"	       			# Same for Visual
LANGUAGE="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
XDG_CONFIG_HOME="$HOME/.config"

export XDG_CONFIG_HOME LANGUAGE EDITOR RSYNC_RSH TERM VISUAL

# Load bash functions
if [ -d "$DOTFILES/sh_functions.d" ]; then
    for FILE in "$DOTFILES"/sh_functions.d/*sh; do
        source "$FILE"
    done
    export BASH_FUNCTIONS_LOADED="yes"
else
    unset BASH_FUNCTIONS_LOADED
fi

# load additional config if exists
if [ -d "$DOTFILES/sh_config.d" ]; then
    for FILE in "$DOTFILES"/sh_config.d/*sh; do
        source "$FILE"
    done
fi

# Load bash completion
if [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

if [ -d "$DOTFILES/bash_completion.d" ]; then
  for FILE in "$DOTFILES"/bash_completion.d/*sh; do
    source "$FILE"
  done
  export BASH_COMPLETION_LOADED="yes"
else
    unset BASH_COMPLETION_LOADED
fi

export BASH_PROFILE_LOADED="yes"

export NVM_DIR="/usr/local/nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
