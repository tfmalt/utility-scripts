# -*- sh -*-
# @author Thomas Malt
#
# HOMEBREW_GITHUB_API_TOKEN="45ef92b6b2a85077d86e9e7f8e595012f08dc5e6"
HOMEBREW_GITHUB_API_TOKEN="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"

case $(setuptype) in
    macbook)
        export HOMEBREW_GITHUB_API_TOKEN
        [ -t 0 ] && echo -e "$ICON_OK Setting github token for Homebrew"
    ;;
esac
