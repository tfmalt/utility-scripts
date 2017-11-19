# -*- sh -*-
#
# bashrc
#
# source $HOME/src/tfmalt/utility-scripts/config/bashrc_mac.bash
if [[ ! $BASH_PROFILE_LOADED ]]; then
    source $HOME/.bash_profile
fi


export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
