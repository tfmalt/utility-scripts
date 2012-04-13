# -*- sh -*-
# 
# helper completion script
#

CORE="git/startsiden/abcnyheter-core"
MODULES=$CORE/"sites/all/modules/"
UTILS="git/startsiden/abcnyheter-utils"
VAGRANT="git/startsiden/abcnyheter-vagrant-setup/abcnyheter-dev/"
THEME=$CORE/"sites/all/themes"
LIB="git/startsiden/abcnyheter-lib"
FIRES="git/startsiden/abcnyheter-fires"
TESTS="git/startsiden/abcnyheter-selenium-testsuite"

function to {
    case "$1" in
	core)
	    cd $HOME/$CORE/
	    pwd
	    git branch
	    ;;
	modules)
	    cd $HOME/$MODULES/$2
	    pwd
	    git branch
	    ;;
	vagrant)
	    cd $HOME/$VAGRANT
	    case "$2" in 
		ssh) 
		    vagrant ssh
		    ;;
		up)
		    vagrant up
		    ;;
		destroy)
		    vagrant destroy
		    ;;
	    esac 
	    ;;
	utils)
	    cd $HOME/$UTILS
	    pwd
	    git branch
	    ;;
        theme)
            cd $HOME/$THEME/$2
            pwd
            git branch
            ;;
        lib)
            cd $HOME/$LIB
            pwd
            git branch
            ;;
        fires) 
            cd $HOME/$FIRES/
            pwd
            git branch
            ;;
        testsuite)
            cd $HOME/$TESTS/
            pwd
            git branch
            ;;
        api)
            cd $HOME/git/startsiden/abcnyheter-api-$2
            pwd
            git branch
            ;;
	*)
	    echo "Legal target or GTFO!"
	    ;;
    esac
}

_gotocomp() {
    local cur prev opts
    COMPREPLY=()
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"
    opts="core modules vagrant utils theme lib fires api testsuite"

    case "${prev}" in
	modules)
	    COMPREPLY=( $(compgen -W "$(ls $HOME/$MODULES/)" -- ${cur}) )
	    return 0
	    ;;
        theme)
	    COMPREPLY=( $(compgen -W "$(ls $HOME/$THEME/)" -- ${cur}) )
	    return 0
	    ;;
	vagrant)
	    COMPREPLY=( $(compgen -W "ssh up destroy reload" -- ${cur}) )
	    return 0
            ;;
        api)
            COMPREPLY=( $(compgen -W "$(ls -d1 $HOME/git/startsiden/abcnyheter-api-* | cut -f3- -d'-')" -- ${cur}) )
            return 0
	    ;;
	core|utils|lib|fires|testsuite)
	    # COMPREPLY=""
	    return 0
	    ;;
    esac

    if [[ ${cur} == * ]]; then
	COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
	return 0
    fi
}

complete -F _gotocomp to

export HELPER_COMPLETION_LOADED="yes"
