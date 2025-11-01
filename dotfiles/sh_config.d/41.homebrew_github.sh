# -*- sh -*-
# @author Thomas Malt
#
# Configure Homebrew for macOS and Linux systems.
# Sets up Homebrew environment and optionally loads GitHub API token.
# Do not commit secrets here. Set HOMEBREW_GITHUB_API_TOKEN externally.

case $(setuptype) in
    macbook)
        # macOS - Homebrew is typically installed via official installer
        # Check common Homebrew installation paths
        if [ -x /opt/homebrew/bin/brew ]; then
            # Apple Silicon Macs
            eval "$(/opt/homebrew/bin/brew shellenv)"
            [ -t 0 ] && echo -e "${ICON_OK:-✓} Homebrew initialized (Apple Silicon)"
        elif [ -x /usr/local/bin/brew ]; then
            # Intel Macs
            eval "$(/usr/local/bin/brew shellenv)"
            [ -t 0 ] && echo -e "${ICON_OK:-✓} Homebrew initialized (Intel)"
        fi
        ;;

    linux-server|linux|linux-virtual)
        # Linux - Homebrew installs to /home/linuxbrew/.linuxbrew
        if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            [ -t 0 ] && echo -e "${ICON_OK:-✓} Homebrew initialized (Linux)"
        elif [ -d /home/linuxbrew/.linuxbrew ]; then
            [ -t 0 ] && echo -e "${ICON_WARN:-⚠️ } Homebrew directory found but brew binary not executable"
        fi
        ;;
esac

# Configure Homebrew GitHub token if provided via environment
# This helps avoid GitHub API rate limits when installing from Homebrew
if command -v brew &> /dev/null; then
    if [ -n "$HOMEBREW_GITHUB_API_TOKEN" ]; then
        export HOMEBREW_GITHUB_API_TOKEN
        [ -t 0 ] && echo -e "${ICON_OK:-✓} Using HOMEBREW_GITHUB_API_TOKEN from environment"
    fi
fi
