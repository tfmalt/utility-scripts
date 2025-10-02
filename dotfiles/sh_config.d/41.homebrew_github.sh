# -*- sh -*-
# @author Thomas Malt
#
# Configure Homebrew GitHub token if provided via environment.
# Do not commit secrets here. Set HOMEBREW_GITHUB_API_TOKEN externally.

case $(setuptype) in
    macbook)
        if [ -n "$HOMEBREW_GITHUB_API_TOKEN" ]; then
          export HOMEBREW_GITHUB_API_TOKEN
          [ -t 0 ] && echo -e "$ICON_OK Using HOMEBREW_GITHUB_API_TOKEN from environment for Homebrew"
        else
          [ -t 0 ] && echo -e "$ICON_INFO HOMEBREW_GITHUB_API_TOKEN not set; proceeding without it"
        fi
    ;;
esac
