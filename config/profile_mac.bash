# -*- sh -*-
# bash profile for my macs
#
# @author Thomas Malt
# 

echo "bash_profile"
uptime

# Setting the path
PATH="/usr/local/bin:$PATH"
PATH="$PATH:$HOME/bin:"
PATH="$PATH:/usr/local/mysql/bin"
PATH="$PATH:/usr/local/sbin"
PATH="$PATH:$HOME/git/startsiden/startsiden-build-tools/bin"
export PATH

# Setting PERL5LIB
PERL5LIB="$PERL5LIB:$HOME/git/startsiden/startsiden-build-tools/lib"
export PERL5LIB

# Locale settings
EDITOR="vim"
RSYNC_RSH="ssh"					# We use ssh for rsync 
TERM="xterm-256color"
VISUAL=$EDITOR	       				# Same for Visual
LSCOLORS=exGxcxdxbxefedabafacad
DIRCOLOR=1
export EDITOR RSYNC_RSH TERM VISUAL LSCOLORS DIRCOLOR

# aliases
alias ls="ls -G"                                                              
alias vboxheadless="VBoxHeadless"
alias week="date +'%A %d %B %k:%M:%S Week %W'"
alias rm="rm -v"                                  #we like to be verbose
alias mv="mv -v"
alias cp="cp -v"

# Load bash functions
if [ -d $HOME/.bash_functions.d ]; then
    for FILE in $HOME/.bash_functions.d/*sh; do
	source $FILE
    done
    export BASH_FUNCTIONS_LOADED="yes"
else
    unset BASH_FUNCTIONS_LOADED
fi

# Load bash completion
if [ -d $HOME/.bash_completion.d ]; then
    for FILE in $HOME/.bash_completion.d/*sh; do
        source $FILE
    done
    export BASH_COMPLETION_LOADED="yes"
else
    unset BASH_COMPLETION_LOADED
fi

# Setting the different command prompts.
case $(setuptype) in
    root)
        echo "root"
        PS1="[\[\e[38;05;9m\]\u\[\e[0m\]@\[\e[38;05;9m\]\h:\w\[\e[1;0m\]] "
        ;;
    laptop)
        echo "laptop"
        PS1="\[\e[38;5;11m\][\[\e[0m\]\u\[\e[38;5;45m\]@\[\e[0m\]\h"
        PS1="${PS1}\[\e[38;5;11m\]:\[\e[0m\]\w\[\e[38;5;11m\]]\[\e[0m\] "
        ;;
    *)
        echo "default"
        PS1="\[\033[1;32m\][\[\033[0m\]\u\[\033[0;36m\]@\[\033[0m\]\h"
        PS1="${PS1}\[\033[0;36m\]:\[\033[0m\]\w\[\033[1;32m\]]\[\033[0m\] "
        ;;
esac
export PS1

export BASH_PROFILE_LOADED="yes"

