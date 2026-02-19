# -*- sh -*-
# shellcheck shell=bash
# config snippet to setup paths in a managable way across systems
#
# @author Thomas Malt
#

if [[ -d /snap/bin ]]; then
    PATH="$PATH:/snap/bin"
fi
export PATH
