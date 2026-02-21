# -*- sh -*-
# shellcheck shell=bash
# @author Thomas Malt
#
# Configure Homebrew for macOS and Linux systems.
# Sets up Homebrew environment and optionally loads GitHub API token.
# Do not commit secrets here. Set HOMEBREW_GITHUB_API_TOKEN externally.

if ! envstatus_tool_disabled "homebrew"; then
    case $(setuptype) in
        macbook)
            # macOS - Homebrew is typically installed via official installer
            # Check common Homebrew installation paths
            if [ -x /opt/homebrew/bin/brew ]; then
                # Apple Silicon Macs
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [ -x /usr/local/bin/brew ]; then
                # Intel Macs
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            ;;

        linux-server|linux|linux-virtual)
            # Linux - Homebrew installs to /home/linuxbrew/.linuxbrew
            if [ -x /home/linuxbrew/.linuxbrew/bin/brew ]; then
                eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
            elif [ -d /home/linuxbrew/.linuxbrew ]; then
                status_warn "homebrew" "directory found but brew binary is not executable"
            fi
            ;;
    esac
fi

# Disable Homebrew environment hints
export HOMEBREW_NO_ENV_HINTS=1

# Configure Homebrew GitHub token if provided via environment
# This helps avoid GitHub API rate limits when installing from Homebrew
if ! envstatus_tool_disabled "homebrew" && command -v brew &> /dev/null; then
    if [ -n "$HOMEBREW_GITHUB_API_TOKEN" ]; then
        export HOMEBREW_GITHUB_API_TOKEN
    fi
fi
