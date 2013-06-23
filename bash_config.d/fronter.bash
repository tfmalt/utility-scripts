
# Adding extlibs
UNAME=$(uname)
if [[ $(hostname | grep fronter) ]]; then
    EXTLIBS_ROOT="$HOME/fronterworld/source2/extlibs"
else 
    EXTLIBS_ROOT="$HOME/src/fronter/fronterworld/source2/extlibs"
fi

export EXTLIBS_ROOT

