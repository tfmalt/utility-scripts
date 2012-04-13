# -*- sh -*-
#
# Load the bash_completion scripts from brew if they exist
#
# @author Thomas Malt <thomas@malt.no>
#

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    source $(brew --prefix)/etc/bash_completion
    export BREW_COMPLETION_LOADED="yes"
else
    unset BREW_COMPLETION_LOADED
fi
