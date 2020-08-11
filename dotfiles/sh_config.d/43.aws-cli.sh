# -*- sh -*-
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#

case $(setuptype) in
  macbook)
    if [ -x /usr/local/bin/aws_completer]
      complete -C /usr/local/bin/aws_completer aws
      [ -t 0 ] && echo -e "$ICON_OK Found aws-cli. Adding Autocompletion"
    fi  
    ;;
esac

