#!/bin/bash
#
# Run shellcheck on all shell scripts in the repository
# Usage: ./scripts/lint.sh
#

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if shellcheck is installed
if ! command -v shellcheck >/dev/null 2>&1; then
    echo -e "${RED}Error: shellcheck is not installed${NC}"
    echo "Install it with:"
    echo "  macOS:   brew install shellcheck"
    echo "  Ubuntu:  sudo apt-get install shellcheck"
    echo "  Fedora:  sudo dnf install shellcheck"
    exit 1
fi

echo "Running shellcheck on repository..."
echo

# Track errors
ERRORS=0

# Check install.sh
echo -e "${YELLOW}Checking install.sh...${NC}"
if shellcheck install.sh; then
    echo -e "${GREEN}✓ install.sh passed${NC}"
else
    echo -e "${RED}✗ install.sh failed${NC}"
    ((ERRORS++))
fi
echo

# Check shell config files
echo -e "${YELLOW}Checking dotfiles/sh_config.d/*.sh...${NC}"
for file in dotfiles/sh_config.d/*.sh; do
    if [[ -f "$file" ]]; then
        if shellcheck "$file"; then
            echo -e "${GREEN}✓ $file passed${NC}"
        else
            echo -e "${RED}✗ $file failed${NC}"
            ((ERRORS++))
        fi
    fi
done
echo

# Check shell function files
echo -e "${YELLOW}Checking dotfiles/sh_functions.d/*.bash...${NC}"
for file in dotfiles/sh_functions.d/*.bash; do
    if [[ -f "$file" ]]; then
        if shellcheck "$file"; then
            echo -e "${GREEN}✓ $file passed${NC}"
        else
            echo -e "${RED}✗ $file failed${NC}"
            ((ERRORS++))
        fi
    fi
done
echo

# Check scripts directory
echo -e "${YELLOW}Checking scripts/*.sh...${NC}"
for file in scripts/*.sh scripts/*.bash; do
    if [[ -f "$file" ]]; then
        if shellcheck "$file"; then
            echo -e "${GREEN}✓ $file passed${NC}"
        else
            echo -e "${RED}✗ $file failed${NC}"
            ((ERRORS++))
        fi
    fi
done
echo

# Summary
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}All checks passed!${NC}"
    exit 0
else
    echo -e "${RED}Found $ERRORS file(s) with issues${NC}"
    exit 1
fi
