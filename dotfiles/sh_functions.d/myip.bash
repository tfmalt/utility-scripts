#!/bin/bash
#
# Function to reliably fetch the external/public IP address
#
# Copyright (c) 2025 Thomas Malt <thomas@malt.no>
#
# License: MIT
#
# Uses multiple fallback methods to ensure reliability:
# 1. Cloudflare DNS (preferred, since likely using Cloudflare)
# 2. OpenDNS (most reliable DNS-based method)
# 3. HTTP-based services as final fallback
#
# Returns: External IP address on success, exits with error code on failure
#

myip() {
    local ip=""
    local verbose=false

    # Parse options
    if [[ "$1" == "-v" ]] || [[ "$1" == "--verbose" ]]; then
        verbose=true
    fi

    # Method 1: Try Cloudflare DNS first (fast and reliable)
    if [[ "$verbose" == true ]]; then
        echo "Trying Cloudflare DNS..." >&2
    fi
    ip=$(dig +short txt ch whoami.cloudflare @1.0.0.1 2>/dev/null | tr -d '"')
    if [[ -n "$ip" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        [[ "$verbose" == true ]] && echo "Success via Cloudflare DNS" >&2
        echo "$ip"
        return 0
    fi

    # Method 2: Try OpenDNS (gold standard for reliability)
    if [[ "$verbose" == true ]]; then
        echo "Trying OpenDNS..." >&2
    fi
    ip=$(dig @resolver1.opendns.com myip.opendns.com +short 2>/dev/null)
    if [[ -n "$ip" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        [[ "$verbose" == true ]] && echo "Success via OpenDNS" >&2
        echo "$ip"
        return 0
    fi

    # Method 3: Try ifconfig.me (reliable HTTP service)
    if [[ "$verbose" == true ]]; then
        echo "Trying ifconfig.me..." >&2
    fi
    ip=$(curl -s --connect-timeout 5 --max-time 10 ifconfig.me 2>/dev/null)
    if [[ -n "$ip" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        [[ "$verbose" == true ]] && echo "Success via ifconfig.me" >&2
        echo "$ip"
        return 0
    fi

    # Method 4: Try icanhazip.com (simple and fast)
    if [[ "$verbose" == true ]]; then
        echo "Trying icanhazip.com..." >&2
    fi
    ip=$(curl -s --connect-timeout 5 --max-time 10 icanhazip.com 2>/dev/null)
    if [[ -n "$ip" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        [[ "$verbose" == true ]] && echo "Success via icanhazip.com" >&2
        echo "$ip"
        return 0
    fi

    # Method 5: Try api.ipify.org (last resort)
    if [[ "$verbose" == true ]]; then
        echo "Trying api.ipify.org..." >&2
    fi
    ip=$(curl -s --connect-timeout 5 --max-time 10 api.ipify.org 2>/dev/null)
    if [[ -n "$ip" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        [[ "$verbose" == true ]] && echo "Success via api.ipify.org" >&2
        echo "$ip"
        return 0
    fi

    # All methods failed
    [[ "$verbose" == true ]] && echo "ERROR: Failed to retrieve external IP address" >&2
    return 1
}
