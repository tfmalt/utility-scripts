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
# Configuration: ~/.config/cloudflare/ddns.conf.d/*.conf
# State file:    ~/.cache/cloudflare-ddns/current-ip
# Logs:          ~/.cache/cloudflare-ddns/ddns.log
#
# Each conf file is fully self-contained:
#   CF_ZONE="example.com"
#   CF_RECORDS="id:name:proxy ..."
#   CF_API_TOKEN="your_token_here"
#

set -euo pipefail

# Configuration
CONF_D_DIR="${HOME}/.config/cloudflare/ddns.conf.d"
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

# Collect all account config files from conf.d directory
collect_config_files() {
    if [ ! -d "${CONF_D_DIR}" ]; then
        error_exit "Config directory not found: ${CONF_D_DIR}. Run setup first."
    fi

    local files=()
    for f in "${CONF_D_DIR}"/*.conf; do
        [ -f "$f" ] && files+=("$f")
    done

    if [ ${#files[@]} -eq 0 ]; then
        error_exit "No .conf files found in ${CONF_D_DIR}. Run setup first."
    fi

    printf '%s\n' "${files[@]}"
}

# Load a single account config, with variable isolation
load_account_config() {
    local conf_file="$1"

    # Unset to prevent bleed-over between accounts
    unset CF_ZONE CF_RECORDS CF_API_TOKEN

    if [ ! -f "${conf_file}" ]; then
        log "ERROR" "Config file not found: ${conf_file}"
        return 1
    fi

    # shellcheck source=/dev/null
    source "${conf_file}"

    if [ -z "${CF_ZONE:-}" ]; then
        log "ERROR" "CF_ZONE not set in ${conf_file}"
        return 1
    fi

    if [ -z "${CF_RECORDS:-}" ]; then
        log "ERROR" "CF_RECORDS not set in ${conf_file}"
        return 1
    fi

    if [ -z "${CF_API_TOKEN:-}" ]; then
        log "ERROR" "CF_API_TOKEN not set in ${conf_file}"
        return 1
    fi
}

# Get external IP using multiple fallback methods
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

# Update all configured DNS records for the current account
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

# Process a single account config file
process_account() {
    local conf_file="$1"
    local current_ip="$2"
    local account_name
    account_name=$(basename "${conf_file}" .conf)

    log "INFO" "Processing account: ${account_name}"

    if ! load_account_config "${conf_file}"; then
        log "ERROR" "Skipping account ${account_name} due to config errors"
        return 1
    fi

    if ! update_all_records "${current_ip}"; then
        log "ERROR" "DNS update failed for account: ${account_name}"
        return 1
    fi

    return 0
}

# Main execution
main() {
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

    # Collect account configs
    local config_files=()
    while IFS= read -r f; do
        config_files+=("$f")
    done < <(collect_config_files)

    log "INFO" "Found ${#config_files[@]} account(s) to process"

    # Get current external IP (fetched once, shared across all accounts)
    log "INFO" "Checking external IP address..."
    local current_ip
    if ! current_ip=$(get_external_ip); then
        error_exit "Failed to retrieve external IP address"
    fi
    log "INFO" "Current external IP: ${current_ip}"

    # Check if update is needed
    local cached_ip
    cached_ip=$(get_cached_ip)

    if [ "${current_ip}" = "${cached_ip}" ] && [ "${force}" != true ]; then
        log "INFO" "IP address unchanged (${current_ip}), no update needed"
        exit 0
    fi

    if [ "${force}" = true ]; then
        log "INFO" "Force update requested"
    else
        log "INFO" "IP address changed from ${cached_ip:-none} to ${current_ip}"
    fi

    # Process all accounts
    local overall_success=true
    for conf_file in "${config_files[@]}"; do
        if ! process_account "${conf_file}" "${current_ip}"; then
            overall_success=false
        fi
    done

    # Only update the IP cache if all accounts succeeded
    if [ "${overall_success}" = true ]; then
        echo "${current_ip}" > "${STATE_FILE}"
        log "INFO" "All accounts updated successfully"
    else
        error_exit "DNS update failed for one or more accounts"
    fi
}

# Run main function
main "$@"
