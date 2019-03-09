# -*- sh -*-
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#

case $(setuptype) in
  linux-server)
    PATH="$PATH:$HOME/.local/bin"
    ;;
esac
export PATH

