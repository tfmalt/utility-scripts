# -*- sh -*-
# 
# helper completion script
#

SRC="src/startsiden"
CORE="$SRC/abcnyheter-core"
MODULES=$CORE/"sites/all/modules/"
UTILS="$SRC/abcnyheter-utils"
VAGRANT="$SRC/abcnyheter-vagrant-setup"
THEME=$CORE/"sites/all/themes"
LIB="$SRC/abcnyheter-lib"
FIRES="$SRC/abcnyheter-fires"
TESTS="$SRC/abcnyheter-selenium-testsuite"
NOVUS="$SRC/novus"

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
	    cd $HOME/$VAGRANT/$2
	    case "$3" in 
		ssh|up|destroy) 
		    vagrant $3
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
            cd $HOME/$SRC/abcnyheter-api-$2
            pwd
            git branch
            ;;
        novus)
            cd $HOME/${NOVUS}-${2}
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
    _get_comp_words_by_ref -n : cur prev;

    opts="novus core modules vagrant utils theme lib fires api testsuite"

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
	    COMPREPLY=( $(compgen -W "$(__vagrant_dirs)" -- ${cur}) )
	    return 0
            ;;
        api)
            COMPREPLY=( $(compgen -W "$(ls -d1 $HOME/src/startsiden/abcnyheter-api-* | cut -f3- -d'-')" -- ${cur}) )
            return 0
	    ;;
        novus)
            COMPREPLY=( $(compgen -W "$(ls -d1 ${HOME}/${NOVUS}-* | cut -f2- -d'-')" -- ${cur}))
            return 0
            ;;
	core|utils|lib|fires|testsuite)
	    # COMPREPLY=""
	    return 0
	    ;;
    esac

    for dir in $(__vagrant_dirs); do
        if [[ $prev == $dir ]]; then
            COMPREPLY=( $(compgen -W "ssh status suspend up halt destroy" -- ${cur}))
            return 0
        fi 
    done

    if [[ ${cur} == * ]]; then
	    COMPREPLY=( $(compgen -W "${opts}" -- ${cur}) )
	    return 0
    fi
}

__vagrant_dirs() {
    find $HOME/$VAGRANT -name Vagrantfile -exec dirname {} \; | cut -d'/' -f7 
}

complete -F _gotocomp to

export HELPER_COMPLETION_LOADED="yes"
