# -*- sh -*-
# Setting up powerline for bash
#

if [ -x /usr/bin/powerline ]; then
  /usr/bin/powerline-daemon -q
  export POWERLINE_BASH_CONTINUATION=1
  export POWERLINE_BASH_SELECT=1
  source /usr/share/powerline/bindings/bash/powerline.sh
  export BASH_POWERLINE_LOADED="yes"
else
  export BASH_POWERLINE_LOADED="no"
fi

echo " - powerline loaded for bash: $BASH_POWERLINE_LOADED"
