# -*- sh -*-
# bashrc - setup file for bash

# Copyright (C) 2002-2012, Thomas Malt
#


PATH="/usr/local/bin:$PATH:$HOME/bin:/usr/local/mysql/bin:/usr/local/sbin"
PATH=$PATH:$HOME/src/startsiden/startsiden-build-tools/bin

# Locale settings
EDITOR="emacs"
HISTIGNORE='&:d:ls:lm:lm *'			# Ignore stuff
LANG=en_US.UTF-8
LANGUAGE=en_US.UTF-8
LC_ALL=en_US.UTF-8
LC_MONETARY=nb_NO.UTF-8
LC_TIME=nb_NO.UTF-8
LESS="-M-Q-r"          				# Less stuff 
LESSCHARDEF="8bcccbcc13b.4b95.33b."		#
LESSEDIT="%E ?lt+%lt. %f" 			# 
PERL5LIB="$PERL5LIB:$HOME/src/startsiden/startsiden-build-tools/lib"
RSYNC_RSH="ssh"					# We use ssh for rsync 
TERM="xterm-256color"
VISUAL=$EDITOR	       				# Same for Visual

# Export all the variables
export LANG LC_TIME LC_MONETARY TERM EDITOR VISUAL LESS  LESSEDIT LESSOPEN 
export HISTIGNORE LESSCHARDEF RSYNC_RSH  LC_ALL LANGUAGE PATH PERL5LIB TERM

unset MAILCHECK
# 
# Different command prompts.

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

case `uname` in
    Darwin)
	LSCOLORS=exGxcxdxbxefedabafacad
	DIRCOLOR=1
	MANPATH=$MANPATH:/opt/local/man
	EDITOR="emacs"
	export LSCOLORS MANPATH
	;;
esac


# ALIASES
case `uname` in
    Darwin)
	alias ls="ls -G"
	;;
    Linux)
	alias ls="ls --color=always"
	;;
esac

alias week="date +'%A %d %B %k:%M:%S Week %W'"
alias rm="rm -v"                                  #we like to be verbose
alias mv="mv -v"
alias cp="cp -v"

