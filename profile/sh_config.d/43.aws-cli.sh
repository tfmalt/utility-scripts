# -*- sh -*-
# shellcheck shell=bash
# config snippet to setup AWS CLI completion
#
# @author Thomas Malt
#

case $(setuptype) in
  macbook)
    if [ -x /usr/local/bin/aws_completer ]; then
      complete -C /usr/local/bin/aws_completer aws
      [ -t 0 ] && echo -e "$ICON_OK Found aws-cli. Adding Autocompletion"
    fi  
    ;;
esac

