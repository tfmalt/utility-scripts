# -*- sh -*-
# @author Thomas Malt
#

if [ -t 0 ]; then
    [ -t 0 ] && echo "uptime: " $(uptime)
    [ -t 0 ] && echo ""
fi

if [ -t 0 ]; then
    echo " - setuptype: $(setuptype)"
fi
