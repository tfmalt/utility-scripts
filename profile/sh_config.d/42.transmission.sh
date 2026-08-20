# -*- sh -*-
# shellcheck shell=bash
# Transmission RPC credentials are stored outside the profile repository.

TRANSMISSION_REMOTE_NETRC="${XDG_CONFIG_HOME:-$HOME/.config}/transmission/remote.netrc"
TRANSMISSION_REMOTE_HOST="${TRANSMISSION_REMOTE_HOST:-127.0.0.1:9091}"
export TRANSMISSION_REMOTE_NETRC TRANSMISSION_REMOTE_HOST

if ! envstatus_tool_disabled "transmission" && [ ! -f "$TRANSMISSION_REMOTE_NETRC" ]; then
    status_warn "transmission" "credentials not configured; create $TRANSMISSION_REMOTE_NETRC"
fi

# Use command transmission-remote for one-off connections to another daemon.
transmission-remote() {
    command transmission-remote "$TRANSMISSION_REMOTE_HOST" \
        --netrc "$TRANSMISSION_REMOTE_NETRC" "$@"
}
