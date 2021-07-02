# -*- sh -*-
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#

# lets see
case $(uname) in
Linux)
  alias ls="ls --color=auto"
  ;;
Darwin)
  alias ls="ls -G"
  ;;
esac

case $(setuptype) in
linux-server) ;;

windows)
  alias dotnet="dotnet.exe"
  ;;
esac

alias vboxheadless="VBoxHeadless"
alias week="date +'%A %d %B %k:%M:%S Week %W'"
alias rm="rm -v" #we like to be verbose
alias mv="mv -v"
alias cp="cp -v"
