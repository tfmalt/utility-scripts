# -*- sh -*-
# bash profile for my macs
#
# @author Thomas Malt
#

if [ -n "$PS1" ]; then
    echo "uptime: " $(uptime)
    echo ""
fi

if (( $EUID == 0 )); then
    # echo "Logged in as root: loading bash-completion"
    if [ -f /usr/share/bash-completion/bash_completion ]; then
        source /usr/share/bash-completion/bash_completion
    elif [ -f /etc/bash_completion ]; then
        source /etc/bash_completion
    fi
fi

# setting vi mode
set -o vi

# Setting the path
PATH="/usr/local/bin:/usr/local/sbin:$PATH"

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

export LANGUAGE EDITOR RSYNC_RSH TERM VISUAL DIRCOLOR

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

# load additional config if exists
if [ -d $HOME/.bash_config.d ]; then
    for FILE in $HOME/.bash_config.d/*sh; do
        source $FILE
    done
fi

# Linux and MacOS specific setup
case $(uname) in
    Linux)
        alias ls="ls --color=auto"
        eval $(dircolors -b $HOME/.dircolors/dircolors.256dark)
        ;;
    Darwin)
        alias ls="ls -G"
        export LSCOLORS=exGxcxdxbxefedabafacad
        # export JAVA_HOME=$(/usr/libexec/java_home)
        # export EC2_HOME="${HOME}/src/ec2-api-tools-1.6.13.0"
        # export PATH=$PATH:$EC2_HOME/bin
        ;;
esac

alias vboxheadless="VBoxHeadless"
alias week="date +'%A %d %B %k:%M:%S Week %W'"
alias rm="rm -v"                                  #we like to be verbose
alias mv="mv -v"
alias cp="cp -v"

# Setting the different command prompts.
GITBRANCH="\[\e[38;5;196m\]\$(__git_ps1 ' %s')\[\e[0m\]"
case $(setuptype) in
    root)
        PS1="[\[\e[38;05;9m\]\u\[\e[0m\]@\[\e[38;05;9m\]\h:\w\[\e[1;0m\]] "
        ;;
    laptop)
        PS1="\[\e[38;5;214m\][\[\e[38;5;228m\]\u\[\e[38;5;214m\]@\[\e[38;5;228m\]\h"
        PS1="${PS1}\[\e[38;5;214m\]:\[\e[0m\]\w$GITBRANCH\[\e[38;5;214m\]]\[\e[0m\] "
        ;;
    lxc)
        PS1="\[\e[38;5;53m\][\[\e[38;5;77m\]\u\[\e[38;5;53m\]@\[\e[38;5;77m\]\h"
        PS1="${PS1}\[\e[38;5;53m\]:\[\e[0m\]\w$GITBRANCH\[\e[38;5;53m\]]\[\e[0m\] "
        ;;
    nrk-laptop)
        PS1="\[\e[38;5;214m\][\[\e[38;5;228m\]tm\[\e[38;5;214m\]@\[\e[38;5;228m\]nrk"
        PS1="${PS1}\[\e[38;5;214m\]:\[\e[0m\]\w$GITBRANCH\[\e[38;5;214m\]]\[\e[0m\] "
        ;;
    linux-server)
        PS1="\[\033[38;5;45m\][\[\033[38;5;87m\]\u\[\033[38;5;45m\]"
        PS1="${PS1}@\[\033[38;5;87m\]\h"
        PS1="${PS1}\[\033[38;5;45m\]:\[\033[38;5;87m\]\w$GITBRANCH\[\033[38;5;45m\]]\[\033[0m\] "
	;;
    linux-virtual)
        PS1="\[\e[38;5;14m\][\[\033[0m\]\u\[\033[0;36m\]@\[\033[0m\]\h"
        PS1="${PS1}\[\033[0;36m\]:\[\033[0m\]\w$GITBRANCH\[\e[38;5;14m\]]\[\033[0m\] "
        ;;
    linux)
        PS1="\[\033[1;32m\][\[\033[0m\]\u\[\033[0;36m\]@\[\033[0m\]\h"
        PS1="${PS1}\[\033[0;36m\]:\[\033[0m\]\w$GITBRANCH\[\033[1;32m\]]\[\033[0m\] "
	;;
    linux-rpi)
        PI=$'\u03C0'
        SIGMA=$'\u03A3'

        PS1="\[\033[38;5;162m\][\[\033[38;5;174m\]\u@"

        if [ $(hostname) == "pi" ]; then
            PS1="${PS1}${PI}"
        elif [ $(hostname) == "sigma" ]; then
            PS1="${PS1}${SIGMA}"
        fi

        PS1="${PS1}\[\033[38;5;162m\]:\[\033[0m\]\w$GITBRANCH\[\033[38;5;162m\]]\[\033[0m\] "
	;;
    *)
        PS1="\[\033[1;32m\][\[\033[0m\]\u\[\033[0;36m\]@\[\033[0m\]\h"
        PS1="${PS1}\[\033[0;36m\]:\[\033[0m\]\w$GITBRANCH\[\033[1;32m\]]\[\033[0m\] "
        ;;
esac
export PS1

export BASH_PROFILE_LOADED="yes"
