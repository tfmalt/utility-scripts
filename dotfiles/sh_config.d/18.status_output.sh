# -*- sh -*-
# @author Thomas Malt
#

[ -t 0 ] && echo "uptime: " $(uptime)
[ -t 0 ] && echo ""
[ -t 0 ] && echo -e "$ICON_OK setuptype: $(setuptype)"
