# -*- sh -*-
# @author Thomas Malt
#
# HOMEBREW_GITHUB_API_TOKEN="45ef92b6b2a85077d86e9e7f8e595012f08dc5e6"
HOMEBREW_GITHUB_API_TOKEN="a1543e0caed855e7b478ad6981c54136d1113a6d"
case $(setuptype) in
    laptop)
        export HOMEBREW_GITHUB_API_TOKEN
        if [ -t 0 ]; then
            echo " - exporting Github token for Homebrew"
        fi
    ;;
esac
