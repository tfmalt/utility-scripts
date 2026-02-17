#!/bin/bash
#
# Cloudflare Dynamic DNS Update Script
#
# Copyright (c) 2025 Thomas Malt <thomas@malt.no>
# License: MIT
#
# This script updates Cloudflare DNS A records when the external IP changes.
# Designed to run via systemd timer or cron for automatic updates.
#
# Configuration file: ~/.config/cloudflare/ddns.conf
# State file: ~/.cache/cloudflare-ddns/current-ip
# Credentials: ~/.config/cloudflare/credentials (CF_API_TOKEN)
#

set -euo pipefail

# Configuration
CONFIG_FILE="${HOME}/.config/cloudflare/ddns.conf"
STATE_DIR="${HOME}/.cache/cloudflare-ddns"
STATE_FILE="${STATE_DIR}/current-ip"
LOG_FILE="${STATE_DIR}/ddns.log"

# Ensure state directory exists
mkdir -p "${STATE_DIR}"

# Logging function
log() {
    local level="$1"
    shift
    local message="$*"
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[${timestamp}] [${level}] ${message}" | tee -a "${LOG_FILE}"
}

# Error handler
error_exit() {
    log "ERROR" "$1"
    exit 1
}

# Check for required commands
check_dependencies() {
    local missing=()

    for cmd in flarectl dig curl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        error_exit "Missing required commands: ${missing[*]}"
    fi
}

# Load configuration
load_config() {
    if [ ! -f "${CONFIG_FILE}" ]; then
        error_exit "Configuration file not found: ${CONFIG_FILE}. Run setup first."
    fi

    # Source the config file
    # shellcheck source=/dev/null
    source "${CONFIG_FILE}"

    # Validate required variables
    if [ -z "${CF_ZONE:-}" ]; then
        error_exit "CF_ZONE not set in ${CONFIG_FILE}"
    fi

    if [ -z "${CF_RECORDS:-}" ]; then
        error_exit "CF_RECORDS not set in ${CONFIG_FILE}"
    fi

    # Validate CF_API_TOKEN is available
    if [ -z "${CF_API_TOKEN:-}" ]; then
        error_exit "CF_API_TOKEN not set. Check ~/.config/cloudflare/credentials"
    fi
}

# Get external IP using the myip function or fallback methods
get_external_ip() {
    local ip=""

    # Try Cloudflare DNS first
    ip=$(dig +short txt ch whoami.cloudflare @1.0.0.1 2>/dev/null | tr -d '"')
    if [[ -n "$ip" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
        return 0
    fi

    # Fallback to OpenDNS
    ip=$(dig @resolver1.opendns.com myip.opendns.com +short 2>/dev/null)
    if [[ -n "$ip" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
        return 0
    fi

    # Fallback to HTTP
    ip=$(curl -s --connect-timeout 5 --max-time 10 ifconfig.me 2>/dev/null)
    if [[ -n "$ip" ]] && [[ "$ip" =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
        echo "$ip"
        return 0
    fi

    return 1
}

# Read cached IP
get_cached_ip() {
    if [ -f "${STATE_FILE}" ]; then
        cat "${STATE_FILE}"
    else
        echo ""
    fi
}

# Update a single DNS record
update_dns_record() {
    local record_id="$1"
    local record_name="$2"
    local new_ip="$3"
    local proxy="$4"

    log "INFO" "Updating ${record_name} (ID: ${record_id}) to ${new_ip} (proxy: ${proxy})"

    # Build flarectl command
    local cmd="flarectl dns update --zone \"${CF_ZONE}\" --id \"${record_id}\" --content \"${new_ip}\""

    # Add proxy flag if specified
    if [ "${proxy}" = "true" ]; then
        cmd="${cmd} --proxy"
    fi

    # Execute update
    if eval "${cmd}" >> "${LOG_FILE}" 2>&1; then
        log "INFO" "Successfully updated ${record_name}"
        return 0
    else
        log "ERROR" "Failed to update ${record_name}"
        return 1
    fi
}

# Update all configured DNS records
update_all_records() {
    local new_ip="$1"
    local success=true

    # Parse CF_RECORDS (format: "id:name:proxy id:name:proxy ...")
    for record in ${CF_RECORDS}; do
        IFS=':' read -r record_id record_name proxy <<< "${record}"

        if ! update_dns_record "${record_id}" "${record_name}" "${new_ip}" "${proxy}"; then
            success=false
        fi
    done

    if [ "${success}" = true ]; then
        return 0
    else
        return 1
    fi
}

# Main execution
main() {
    local current_ip
    local cached_ip
    local force=false

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -f|--force)
                force=true
                shift
                ;;
            -v|--verbose)
                set -x
                shift
                ;;
            *)
                echo "Usage: $0 [-f|--force] [-v|--verbose]"
                echo "  -f, --force    Force update even if IP hasn't changed"
                echo "  -v, --verbose  Enable verbose output"
                exit 1
                ;;
        esac
    done

    # Check dependencies
    check_dependencies

    # Load configuration
    load_config

    # Get current external IP
    log "INFO" "Checking external IP address..."
    if ! current_ip=$(get_external_ip); then
        error_exit "Failed to retrieve external IP address"
    fi

    log "INFO" "Current external IP: ${current_ip}"

    # Get cached IP
    cached_ip=$(get_cached_ip)

    # Check if update is needed
    if [ "${current_ip}" = "${cached_ip}" ] && [ "${force}" != true ]; then
        log "INFO" "IP address unchanged (${current_ip}), no update needed"
        exit 0
    fi

    if [ "${force}" = true ]; then
        log "INFO" "Force update requested"
    else
        log "INFO" "IP address changed from ${cached_ip:-none} to ${current_ip}"
    fi

    # Update all DNS records
    if update_all_records "${current_ip}"; then
        # Save new IP to cache
        echo "${current_ip}" > "${STATE_FILE}"
        log "INFO" "DNS update completed successfully"
    else
        error_exit "DNS update failed for one or more records"
    fi
}

# Run main function
main "$@"
