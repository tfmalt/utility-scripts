#!/bin/bash
#
# Cloudflare Dynamic DNS Setup Script
#
# Copyright (c) 2025 Thomas Malt <thomas@malt.no>
# License: MIT
#
# This script sets up the Cloudflare DDNS system:
# - Creates configuration files
# - Installs systemd service and timer
# - Configures DNS records to update
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
CONFIG_FILE="${CONFIG_DIR}/ddns.conf"
CREDENTIALS_FILE="${CONFIG_DIR}/credentials"
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

# Check for Cloudflare API token
check_credentials() {
    info "Checking Cloudflare credentials..."

    if [ ! -f "${CREDENTIALS_FILE}" ]; then
        error "Cloudflare credentials file not found: ${CREDENTIALS_FILE}"
        echo ""
        echo "Please create the credentials file first:"
        echo "  mkdir -p ${CONFIG_DIR}"
        echo "  touch ${CREDENTIALS_FILE}"
        echo "  chmod 600 ${CREDENTIALS_FILE}"
        echo "  echo 'export CF_API_TOKEN=your_token_here' > ${CREDENTIALS_FILE}"
        echo ""
        exit 1
    fi

    # Source credentials and check token
    # shellcheck source=/dev/null
    source "${CREDENTIALS_FILE}"

    if [ -z "${CF_API_TOKEN:-}" ]; then
        error_exit "CF_API_TOKEN not found in ${CREDENTIALS_FILE}"
    fi

    success "Cloudflare credentials found"
}

# Configure DNS records
configure_records() {
    info "Configuring DNS records..."
    echo ""

    # Prompt for zone
    read -rp "Enter your Cloudflare zone (e.g., malt.no): " zone
    if [ -z "${zone}" ]; then
        error_exit "Zone cannot be empty"
    fi

    echo ""
    info "Listing DNS records for zone: ${zone}"
    echo ""

    # List A records in the zone
    if ! flarectl dns list --zone "${zone}" --type A 2>/dev/null; then
        error_exit "Failed to list DNS records. Check your zone name and API token permissions."
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

    # Create configuration file
    mkdir -p "${CONFIG_DIR}"
    cat > "${CONFIG_FILE}" <<EOF
# Cloudflare DDNS Configuration
# Generated: $(date)

# Cloudflare zone (domain)
CF_ZONE="${zone}"

# DNS records to update (space-separated)
# Format: record_id:record_name:proxy
CF_RECORDS="${records[*]}"
EOF

    chmod 600 "${CONFIG_FILE}"
    success "Configuration saved to ${CONFIG_FILE}"

    # Show configuration summary
    echo ""
    info "Configuration summary:"
    echo "  Zone: ${zone}"
    echo "  Records:"
    for record in "${records[@]}"; do
        IFS=':' read -r id name proxy <<< "${record}"
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
    # Replace %h with actual home directory and repo path
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
    echo "  # Disable timer"
    echo "  systemctl --user stop cloudflare-ddns.timer"
    echo "  systemctl --user disable cloudflare-ddns.timer"
    echo ""
}

# Main installation flow
main() {
    echo ""
    echo "============================================"
    echo "  Cloudflare Dynamic DNS Setup"
    echo "============================================"
    echo ""

    # Always check dependencies
    check_dependencies
    check_credentials

    # Check if already configured
    if [ -f "${CONFIG_FILE}" ]; then
        warning "Configuration file already exists: ${CONFIG_FILE}"
        read -rp "Do you want to reconfigure DNS records? (y/N): " reconfigure
        if [[ "${reconfigure}" =~ ^[Yy]$ ]]; then
            configure_records
        else
            info "Keeping existing DNS configuration"
        fi
    else
        configure_records
    fi

    # Install systemd files (always update them)
    install_systemd

    # Enable timer
    enable_timer

    # Create cache directory
    mkdir -p "${CACHE_DIR}"

    # Show status
    show_status
}

# Run main function
main "$@"
