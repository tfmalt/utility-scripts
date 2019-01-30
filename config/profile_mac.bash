# -*- sh -*-
# bash profile
#
# @author Thomas Malt
#

# setting vi mode
set -o vi

# Setting the path
PATH="/bin:/usr/local/bin:/usr/local/sbin:$PATH"

[ -d $HOME/bin ]            && PATH=$PATH:$HOME/bin
[ -d /usr/local/mysql/bin ] && PATH=$PATH:/usr/local/mysql/bin
[ -d $HOME/pear/bin ]       && PATH=$PATH:$HOME/pear/bin
[ -d /opt/packer ]          && PATH=$PATH:/opt/packer
[ -d $HOME/lib/packer ]     && PATH=$PATH:$HOME/lib/packer

export PATH PERL5LIB

# Locale settings
EDITOR="vim"
RSYNC_RSH="ssh"					# We use ssh for rsync
TERM="xterm-256color"
VISUAL=$EDITOR	       				# Same for Visual
DIRCOLOR=1
LANGUAGE="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_ALL="en_US.UTF-8"
XDG_CONFIG_HOME=$HOME/.config

export XDG_CONFIG_HOME LANGUAGE EDITOR RSYNC_RSH TERM VISUAL DIRCOLOR

# Load bash functions
if [ -d $HOME/.bash_functions.d ]; then
    for FILE in $HOME/.bash_functions.d/*sh; do
	source $FILE
    done
    export BASH_FUNCTIONS_LOADED="yes"
else
    unset BASH_FUNCTIONS_LOADED
fi

# load additional config if exists
if [ -d $HOME/.bash_config.d ]; then
    for FILE in $HOME/.bash_config.d/*sh; do
        source $FILE
    done
fi

# Load bash completion
if [ -f /etc/bash_completion ]; then
  source /etc/bash_completion
fi

if [ -d $HOME/.bash_completion.d ]; then
  for FILE in $HOME/.bash_completion.d/*sh; do
    source $FILE
  done
  export BASH_COMPLETION_LOADED="yes"
else
    unset BASH_COMPLETION_LOADED
fi

export BASH_PROFILE_LOADED="yes"
[ -t 0 ] && echo ""

