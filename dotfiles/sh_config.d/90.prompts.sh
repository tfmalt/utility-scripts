
if [[ $SHELL == *bash ]]; then
  # Setting the different command prompts.
  GITBRANCH="\[\e[38;5;196m\]\$(__git_ps1 ' %s')\[\e[0m\]"
  case $(setuptype) in
      root)
          PS1="[\[\e[38;05;9m\]\u\[\e[0m\]@\[\e[38;05;9m\]\h:\w\[\e[1;0m\]] "
          ;;
      macbook)
          PS1="\[\e[38;5;214m\][\[\e[38;5;228m\]\u\[\e[38;5;214m\]@\[\e[38;5;228m\]\h"
          PS1="${PS1}\[\e[38;5;214m\]:\[\e[0m\]\w$GITBRANCH\[\e[38;5;214m\]]\[\e[0m\] "
          ;;
      lxc)
          PS1="\[\e[38;5;65m\][\[\e[38;5;77m\]\u\[\e[38;5;65m\]@\[\e[38;5;77m\]\h"
          PS1="${PS1}\[\e[38;5;65m\]:\[\e[0m\]\w$GITBRANCH\[\e[38;5;65m\]]\[\e[0m\] "
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
  [ -t 0 ] && echo -e "$ICON_OK Shell is bash. Setting prompt for $(setuptype)"
fi
