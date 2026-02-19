# -*- sh -*-
#
# bash completion script to complete curl command line options
#
# @author Thomas Malt <thomas@malt.no>
#

complete -F _curl_completion curl

_curl_completion() {
    local CURR PREV OPTS

    COMPREPLY=()
    CURR="${COMP_WORDS[COMP_CWORD]}"
    PREV="${COMP_WORDS[COMP_CWORD-1]}"

    # echo ""
    # echo "curr:${CURR}:, prev:${PREV}:"
 
    case $PREV in
         curl)
            case $CURR in
                *)
                    OPTS=$(curl --help | awk '/ -/ {print $1}' | tr "/" " ")
                    COMPREPLY=($(compgen -W "${OPTS}" -- ${CURR}))
                    ;;
            esac
            ;;
    esac
}
