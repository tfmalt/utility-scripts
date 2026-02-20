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
      status_ok "aws-cli" "found; enabling completion"
    fi  
    ;;
esac
