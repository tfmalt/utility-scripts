# -*- sh -*-
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#

case $(setuptype) in
  laptop)
    ssh-add -A 2>/dev/null
    echo " - Adding ssh identities found in keychain to ssh-agent."
    ;;
  linux-rpi|root)
    ;;
esac

