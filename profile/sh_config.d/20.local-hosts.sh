# -*- sh -*-
# shellcheck shell=bash
# shellcheck disable=SC2154
# Local network hostname completion for zsh.
#
# Hostnames are collected from four sources:
#
#   1. $LOCAL_HOSTS_FILE (default: ~/.config/local-hosts) - one hostname per
#      line, or hosts(5)-style lines. Text after # is a comment.
#   2. /etc/hosts (and other NSS hosts sources) through getent.
#   3. ~/.ssh/config Host aliases and unhashed ~/.ssh/known_hosts entries.
#   4. Auto-discovery: ARP/neighbour table entries (including the Windows
#      table when running under WSL) that reverse-resolve to a hostname and
#      forward-resolve again.
#
# Discovery is cached in $XDG_CACHE_HOME/zsh/local-hosts and refreshed in the
# background once the cache is older than $LOCAL_HOSTS_TTL seconds (default
# 900), so tab completion never waits on the network.
#
# The collected names are added to zsh's built-in host completion, which
# covers ssh, scp, sftp, ping, traceroute, wget, host, dig, nslookup, rsync,
# mtr and other commands that complete hostnames.

if [ -z "${ZSH_VERSION:-}" ]; then
    return 0
fi

: "${LOCAL_HOSTS_FILE:=${XDG_CONFIG_HOME:-$HOME/.config}/local-hosts}"
: "${LOCAL_HOSTS_TTL:=900}"

_LOCAL_HOSTS_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/zsh"
_LOCAL_HOSTS_CACHE="$_LOCAL_HOSTS_CACHE_DIR/local-hosts"

# --- hostname sources -------------------------------------------------------

# Curated hostnames from $LOCAL_HOSTS_FILE.
_local_hosts_curated() {
    [ -r "$LOCAL_HOSTS_FILE" ] || return 0

    awk '!/^[[:space:]]*#/ {
             for (i = 1; i <= NF; i++)
                 if ($i !~ /^[0-9a-fA-F.:]+$/)
                     print $i
         }' "$LOCAL_HOSTS_FILE"
}

# Hosts already known to the system: /etc/hosts, ssh config, known_hosts.
_local_hosts_system() {
    if command -v getent >/dev/null 2>&1; then
        getent hosts 2>/dev/null | awk '{ for (i = 2; i <= NF; i++) print $i }'
    fi

    if [ -r "$HOME/.ssh/config" ]; then
        awk 'tolower($1) == "host" {
                 for (i = 2; i <= NF; i++)
                     if ($i !~ /[*?!]/)
                         print $i
             }' "$HOME/.ssh/config"
    fi

    if [ -r "$HOME/.ssh/known_hosts" ]; then
        awk '!/^\|/ && $1 !~ /^#/ {
                 n = split($1, h, ",")
                 for (i = 1; i <= n; i++) {
                     gsub(/^\[/, "", h[i])
                     gsub(/\]:[0-9]+$/, "", h[i])
                     if (h[i] != "") print h[i]
                 }
             }' "$HOME/.ssh/known_hosts"
    fi
}

# IP addresses seen on the local network (WSL includes the Windows ARP table).
_local_hosts_neighbours() {
    if command -v arp.exe >/dev/null 2>&1; then
        arp.exe -a 2>/dev/null |
            awk '$1 ~ /^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$/ { print $1 }'
    fi

    if command -v ip >/dev/null 2>&1; then
        ip neigh show 2>/dev/null | awk '{ print $1 }'
    elif command -v arp >/dev/null 2>&1; then
        arp -an 2>/dev/null | sed -n 's/.*(\([0-9.]*\)).*/\1/p'
    fi
}

# Reverse-resolve the neighbour table into hostnames.
_local_hosts_discover() {
    local ip name

    _local_hosts_neighbours |
        grep -Ev '^(0\.|127\.|169\.254\.|22[4-9]\.|23[0-9]\.|255\.|ff[0-9a-fA-F]{2}:)' |
        sort -u |
        while IFS= read -r ip; do
            name=$(getent hosts "$ip" 2>/dev/null | awk 'NR == 1 { print $2 }')
            if [ -z "$name" ]; then
                name=$(dig +short -x "$ip" 2>/dev/null | sed -n '1s/\.$//p')
            fi
            [ -n "$name" ] || continue

            # Keep only names that resolve, so completion has no dead ends.
            getent hosts "$name" >/dev/null 2>&1 || continue

            printf '%s\n' "$name" | tr '[:upper:]' '[:lower:]'
        done

    return 0
}

# --- discovery cache --------------------------------------------------------

# Rebuild the discovery cache; spawned in the background by _local_hosts_dynamic.
_local_hosts_refresh() {
    local lock="${_LOCAL_HOSTS_CACHE}.lock"
    local tmp="${_LOCAL_HOSTS_CACHE}.$$"

    mkdir -p "$_LOCAL_HOSTS_CACHE_DIR" 2>/dev/null || return 0

    # Break a lock left behind by an interrupted refresh.
    if [ -d "$lock" ] && [ -n "$(find "$lock" -mmin +10 2>/dev/null)" ]; then
        rmdir "$lock" 2>/dev/null
    fi

    mkdir "$lock" 2>/dev/null || return 0
    trap 'rmdir "$lock" 2>/dev/null' EXIT INT TERM

    if _local_hosts_discover >"$tmp" 2>/dev/null; then
        mv -f "$tmp" "$_LOCAL_HOSTS_CACHE"
    else
        rm -f "$tmp"
    fi

    rmdir "$lock" 2>/dev/null
    trap - EXIT INT TERM
}

# Cached discovery results; starts a background refresh when stale.
_local_hosts_dynamic() {
    local now mtime=0

    if [ -r "$_LOCAL_HOSTS_CACHE" ]; then
        now=$(date +%s)
        mtime=$(stat -c %Y "$_LOCAL_HOSTS_CACHE" 2>/dev/null ||
            stat -f %m "$_LOCAL_HOSTS_CACHE" 2>/dev/null || echo 0)
        cat "$_LOCAL_HOSTS_CACHE"
    fi

    if [ -z "${now:-}" ] || (( now - mtime >= LOCAL_HOSTS_TTL )); then
        _local_hosts_refresh >/dev/null 2>&1 & disown 2>/dev/null
    fi
}

# All known hostnames, deduplicated.
_local_hosts_names() {
    {
        _local_hosts_curated
        _local_hosts_system
        _local_hosts_dynamic
    } | awk '/^[a-zA-Z0-9][a-zA-Z0-9._-]*$/ && !/^[0-9.]+$/' | sort -fu
}

# --- zsh completion integration ---------------------------------------------

# Add our hosts to the matches collected by the current completion function.
_local_hosts_compadd() {
    local -a hosts
    local host

    while IFS= read -r host; do
        hosts+=("$host")
    done < <(_local_hosts_names)

    (( ${#hosts} )) || return 1

    compadd -M 'm:{a-zA-Z}={A-Za-z} r:|.=* r:|=*' "$@" -a hosts
}

# Extend the generic host completion used by ping, traceroute, wget, host,
# dig, nslookup, rsync, mtr and friends.
if autoload +X _hosts 2>/dev/null; then
    functions[_local_hosts_orig_generic]=${functions[_hosts]}

    _hosts() {
        local -i ret

        _local_hosts_orig_generic "$@"
        ret=$?

        _local_hosts_compadd "$@" || return "$ret"
        return 0
    }
fi

# Extend ssh, scp and sftp host completion.
if autoload +X _ssh_hosts 2>/dev/null; then
    functions[_local_hosts_orig_ssh]=${functions[_ssh_hosts]}

    _ssh_hosts() {
        local -i ret

        _local_hosts_orig_ssh "$@"
        ret=$?

        _local_hosts_compadd "$@" || return "$ret"
        return 0
    }
fi
