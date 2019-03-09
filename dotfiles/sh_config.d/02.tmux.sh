# -*- sh -*-
#
# execute tmux when the constellations align.
#
# @author Thomas Malt
#

# execute tmux if all constellations line up
if [[ $(command -v tmux) ]] && [[ $- == *i* ]] && [[ -z $TMUX ]] && [[ $TERM != screen* ]]; then 
    exec tmux
fi

if [[ -n $TMUX ]]; then
    [ -t 0 ] && echo "$ICON_OK Running in tmux session."
fi