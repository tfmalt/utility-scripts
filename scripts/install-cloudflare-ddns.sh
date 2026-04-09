#!/bin/bash
#
# Cloudflare Dynamic DNS Setup Script
#
# Copyright (c) 2025 Thomas Malt <thomas@malt.no>
# License: MIT
#
# This script sets up the Cloudflare DDNS system:
# - Creates configuration files in ~/.config/cloudflare/ddns.conf.d/
# - Installs systemd service and timer
# - Configures DNS records to update
#
# Usage:
#   ./install-cloudflare-ddns.sh                # First-time setup
#   ./install-cloudflare-ddns.sh --add-account  # Add another Cloudflare account
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

# Configuration
CONFIG_DIR="${HOME}/.config/cloudflare"
CONF_D_DIR="${CONFIG_DIR}/ddns.conf.d"
CACHE_DIR="${HOME}/.cache/cloudflare-ddns"

SYSTEMD_USER_DIR="${HOME}/.config/systemd/user"
SERVICE_FILE="${SYSTEMD_USER_DIR}/cloudflare-ddns.service"
TIMER_FILE="${SYSTEMD_USER_DIR}/cloudflare-ddns.timer"

# Logging functions
info() {
    echo -e "${BLUE}[INFO]${NC} $*"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $*"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $*"
}

error() {
    echo -e "${RED}[ERROR]${NC} $*"
}

error_exit() {
    error "$*"
    exit 1
}

# Check dependencies
check_dependencies() {
    info "Checking dependencies..."

    local missing=()

    for cmd in flarectl dig curl systemctl; do
        if ! command -v "$cmd" &> /dev/null; then
            missing+=("$cmd")
        fi
    done

    if [ ${#missing[@]} -gt 0 ]; then
        error_exit "Missing required commands: ${missing[*]}"
    fi

    success "All dependencies found"
}

# Configure a single Cloudflare account
configure_account() {
    local conf_name="$1"
    local conf_file="${CONF_D_DIR}/${conf_name}.conf"

    info "Configuring account: ${conf_name}"
    echo ""

    # Prompt for API token
    info "Enter the Cloudflare API token for this account"
    info "(Token needs DNS:Edit permission for the zone)"
    echo ""
    local api_token=""
    while [ -z "${api_token}" ]; do
        read -rsp "API Token: " api_token
        echo ""
        if [ -z "${api_token}" ]; then
            error "API token cannot be empty"
        fi
    done

    # Export token so flarectl can use it for record listing
    export CF_API_TOKEN="${api_token}"

    # Prompt for zone
    echo ""
    read -rp "Enter the Cloudflare zone (e.g., malt.no): " zone
    if [ -z "${zone}" ]; then
        error_exit "Zone cannot be empty"
    fi

    echo ""
    info "Listing A records for zone: ${zone}"
    echo ""

    # List A records in the zone
    if ! flarectl dns list --zone "${zone}" --type A 2>/dev/null; then
        error_exit "Failed to list DNS records. Check zone name and API token permissions."
    fi

    echo ""
    info "Enter the DNS records to update (one per line)"
    info "Format: record_id:record_name:proxy"
    info "Example: 4d4728ba4a3947fe46281e4022284981:api.malt.no:true"
    info "         c0759ad9c78a2d678e6f3a10f9f16c40:ssh.malt.no:false"
    echo ""
    info "Enter a blank line when done:"
    echo ""

    local records=()
    while IFS= read -r line; do
        [ -z "${line}" ] && break
        records+=("${line}")
    done

    if [ ${#records[@]} -eq 0 ]; then
        error_exit "No records configured"
    fi

    # Create conf.d directory
    mkdir -p "${CONF_D_DIR}"

    # Write self-contained config file
    cat > "${conf_file}" <<EOF
# Cloudflare DDNS Configuration — ${conf_name}
# Generated: $(date)

# Cloudflare zone (domain)
CF_ZONE="${zone}"

# DNS records to update (space-separated)
# Format: record_id:record_name:proxy
CF_RECORDS="${records[*]}"

# Cloudflare API token (DNS:Edit permission required)
CF_API_TOKEN="${api_token}"
EOF

    chmod 600 "${conf_file}"
    success "Configuration saved to ${conf_file}"

    # Show configuration summary
    echo ""
    info "Configuration summary:"
    echo "  Zone:   ${zone}"
    echo "  Records:"
    for record in "${records[@]}"; do
        IFS=':' read -r _ name proxy <<< "${record}"
        echo "    - ${name} (proxy: ${proxy})"
    done
}

# Install systemd files
install_systemd() {
    info "Installing systemd service and timer..."

    # Create systemd user directory
    mkdir -p "${SYSTEMD_USER_DIR}"

    # Stop timer if running
    if systemctl --user is-active --quiet cloudflare-ddns.timer 2>/dev/null; then
        info "Stopping existing timer..."
        systemctl --user stop cloudflare-ddns.timer
    fi

    # Copy and customize service file
    sed -e "s|%h|${HOME}|g" \
        -e "s|${HOME}/src/tfmalt/utility-scripts|${REPO_ROOT}|g" \
        "${REPO_ROOT}/systemd/cloudflare-ddns.service" > "${SERVICE_FILE}"

    # Copy timer file
    cp "${REPO_ROOT}/systemd/cloudflare-ddns.timer" "${TIMER_FILE}"

    success "Systemd files installed to ${SYSTEMD_USER_DIR}"
}

# Enable and start timer
enable_timer() {
    info "Enabling and starting systemd timer..."

    # Reload systemd
    systemctl --user daemon-reload

    # Enable timer (start on boot)
    systemctl --user enable cloudflare-ddns.timer

    # Start timer now
    systemctl --user start cloudflare-ddns.timer

    success "Systemd timer enabled and started"
}

# Show status and instructions
show_status() {
    echo ""
    success "Cloudflare DDNS setup complete!"
    echo ""
    info "Useful commands:"
    echo "  # Check timer status"
    echo "  systemctl --user status cloudflare-ddns.timer"
    echo ""
    echo "  # List all timers"
    echo "  systemctl --user list-timers"
    echo ""
    echo "  # View logs"
    echo "  journalctl --user -u cloudflare-ddns -f"
    echo ""
    echo "  # Run manually (force update)"
    echo "  ${SCRIPT_DIR}/cloudflare-ddns.sh --force"
    echo ""
    echo "  # Check service status"
    echo "  systemctl --user status cloudflare-ddns.service"
    echo ""
    echo "  # Add another Cloudflare account"
    echo "  ${SCRIPT_DIR}/install-cloudflare-ddns.sh --add-account"
    echo ""
    echo "  # Disable timer"
    echo "  systemctl --user stop cloudflare-ddns.timer"
    echo "  systemctl --user disable cloudflare-ddns.timer"
    echo ""
}

# Main installation flow
main() {
    local add_account=false

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            --add-account)
                add_account=true
                shift
                ;;
            *)
                echo "Usage: $0 [--add-account]"
                echo "  --add-account  Add another Cloudflare account (skips systemd reinstall)"
                exit 1
                ;;
        esac
    done

    echo ""
    if [ "${add_account}" = true ]; then
        echo "============================================"
        echo "  Cloudflare DDNS — Add Account"
        echo "============================================"
    else
        echo "============================================"
        echo "  Cloudflare Dynamic DNS Setup"
        echo "============================================"
    fi
    echo ""

    check_dependencies

    # Prompt for account/conf name
    echo ""
    info "Existing accounts:"
    if ls "${CONF_D_DIR}"/*.conf 2>/dev/null | xargs -I{} basename {} .conf | sed 's/^/  - /'; then
        true
    else
        echo "  (none)"
    fi
    echo ""
    read -rp "Account name (used as filename, e.g. malt.no): " conf_name
    if [ -z "${conf_name}" ]; then
        error_exit "Account name cannot be empty"
    fi

    local conf_file="${CONF_D_DIR}/${conf_name}.conf"
    if [ -f "${conf_file}" ]; then
        warning "Config already exists: ${conf_file}"
        read -rp "Overwrite? (y/N): " overwrite
        if [[ ! "${overwrite}" =~ ^[Yy]$ ]]; then
            info "Aborted"
            exit 0
        fi
    fi

    configure_account "${conf_name}"

    if [ "${add_account}" = false ]; then
        # First-time setup: install systemd and enable timer
        mkdir -p "${CACHE_DIR}"
        install_systemd
        enable_timer
    fi

    show_status
}

# Run main function
main "$@"
