# -*- sh -*-
# bash profile for my macs
#
# @author Thomas Malt
# 

# Source in bashrc if it is not loaded
if [[ ! $BASHRC_LOADED ]]; then
    source .bashrc
fi

# Load bash completion
if [ -d $HOME/.bash_completion.d ]; then
    for FILE in $HOME/.bash_completion.d/*sh; do
        source $FILE
    done
    export BASH_COMPLETION_LOADED="yes"
else
    unset BASH_COMPLETION_LOADED
fi




