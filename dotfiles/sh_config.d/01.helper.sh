# -*- sh -*-
# Various helpers to pimp my sh
# @author Thomas Malt
#

# Colors
COL_GREEN="\e[32m"
COL_GREEN2="\e[38;05;34m"
COL_BG_BLUE="\e[48;05;33m"
COL_RED="\e[38;05;160m"
COL_STOP="\e[0m"

# Icons
ICON_OK="$COL_GREEN2  ✔$COL_STOP"
ICON_ERR="$COL_RED  ✘$COL_STOP"
ICON_INFO="  ➔"

# delay to set vim mode
KEYTIMEOUT=1
export KEYTIMEOUT ICON_OK ICON_ERR ICON_INFO
