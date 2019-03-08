# -*- sh -*-
# @author Thomas Malt
#
# HOMEBREW_GITHUB_API_TOKEN="45ef92b6b2a85077d86e9e7f8e595012f08dc5e6"
HOMEBREW_GITHUB_API_TOKEN="a1543e0caed855e7b478ad6981c54136d1113a6d"

case $(uname) in
    Darwin)
        export HOMEBREW_GITHUB_API_TOKEN
        [ -t 0 ] && echo " - Running on OSX. Setting github token for Homebrew"
    ;;
esac
