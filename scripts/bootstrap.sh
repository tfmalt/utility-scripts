#!/bin/bash
#
# Optional developer tool bootstrapper for the utility-scripts profile.
#
# Installs the tools that the shell profile configures but does not bundle.
# Run after ./install.sh if you want them; every tool can be skipped.
#
# Usage:
#   ./scripts/bootstrap.sh        # Interactive, confirms each tool
#   ./scripts/bootstrap.sh -y     # Assume yes for every prompt
#   ./scripts/bootstrap.sh -v     # Verbose installer output
#
# Tools: oh-my-zsh, mise, node, gh, claude, cargo,
#        platformio, opencode
#
set -euo pipefail

# Parse command line arguments
VERBOSE=false
SKIP_CONFIRM=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -y|--yes)
            SKIP_CONFIRM=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -v, --verbose   Enable verbose installer output"
            echo "  -y, --yes       Skip confirmation prompts (assume yes)"
            echo "  -h, --help      Show this help message"
            echo ""
            echo "Installs optional tools configured by the profile:"
            echo "  oh-my-zsh, mise, node, gh, claude,"
            echo "  cargo, platformio, opencode"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Installation prefix and Oh My Zsh path
INSTALL_PREFIX="${INSTALL_PREFIX:-$HOME}"
ZSH="$INSTALL_PREFIX/.oh-my-zsh"

PAD=24

pad_output() {
    printf "%-${PAD}s" "$1"
}

log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "  [VERBOSE] $1"
    fi
}

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_dependencies() {
    local missing=()
    command_exists git || missing+=("git")
    command_exists curl || missing+=("curl")

    if [ ${#missing[@]} -gt 0 ]; then
        echo "Error: Missing required dependencies: ${missing[*]}"
        echo "Please install the missing tools and try again."
        exit 1
    fi
}

confirm() {
    local message="$1"
    if [ "$SKIP_CONFIRM" = true ]; then
        log_verbose "Skipping confirmation: $message"
        return 0
    fi

    echo -n "$message (y/N): "
    read -r response
    case "$response" in
        [yY]|[yY][eE][sS])
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# Run a command, hiding output unless verbose mode is on.
run_quiet() {
    if [ "$VERBOSE" = true ]; then
        "$@"
    else
        "$@" > /dev/null 2>&1
    fi
}

# Pipe a remote installer script to a shell, hiding output unless verbose.
# Example: run_remote https://mise.run sh
run_remote() {
    local url="$1"
    shift
    if [ "$VERBOSE" = true ]; then
        curl -fsSL "$url" | "$@"
    else
        { curl -fsSL "$url" | "$@"; } > /dev/null 2>&1
    fi
}

# ---------------------------------------------------------------------------
install_oh_my_zsh() {
    echo -n "$(pad_output "installing oh my zsh"):"
    if [ ! -d "$ZSH" ]; then
        if confirm "Install Oh My Zsh?"; then
            log_verbose "Cloning Oh My Zsh repository to $ZSH"
            run_quiet git clone -c core.eol=lf -c core.autocrlf=false \
                -c fsck.zeroPaddedFilemode=ignore \
                -c fetch.fsck.zeroPaddedFilemode=ignore \
                -c receive.fsck.zeroPaddedFilemode=ignore \
                --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
            echo " Done"
        else
            echo " Skipped"
        fi
    else
        echo " exists"
    fi
}

install_mise() {
    echo -n "$(pad_output "installing mise"):"
    if command_exists mise; then
        echo " exists"
    else
        if confirm "Install mise (polyglot runtime manager)?"; then
            log_verbose "Installing mise from https://mise.run"
            if ! run_remote https://mise.run sh; then
                echo " Failed"
                echo "Error: mise installation failed."
                echo "Try again manually with:"
                echo "  curl -fsSL https://mise.run | sh"
                exit 1
            fi
            echo " Done"
        else
            echo " Skipped"
        fi
    fi
}

install_node() {
    echo -n "$(pad_output "installing node"):"
    if command_exists node; then
        echo " exists"
        return
    fi

    local mise_cmd=""
    if command_exists mise; then
        mise_cmd=$(command -v mise)
    elif [ -x "$INSTALL_PREFIX/.local/bin/mise" ]; then
        mise_cmd="$INSTALL_PREFIX/.local/bin/mise"
    fi

    if [ -z "$mise_cmd" ]; then
        echo " Skipped"
        echo "Error: mise is required to install Node.js. Install mise first."
        return
    fi

    if confirm "Install Node.js (node@latest) via mise globally?"; then
        log_verbose "Installing node@latest via mise ($mise_cmd)"
        if ! run_quiet "$mise_cmd" use -g node@latest; then
            echo " Failed"
            echo "Error: Node.js installation via mise failed."
            echo "Try again manually with:"
            echo "  $mise_cmd use -g node@latest"
            exit 1
        fi

        if [ -d "$INSTALL_PREFIX/.local/bin" ] && [[ ":$PATH:" != *":$INSTALL_PREFIX/.local/bin:"* ]]; then
            PATH="$INSTALL_PREFIX/.local/bin:$PATH"
            export PATH
        fi

        eval "$("$mise_cmd" activate bash)"
        echo " Done"
    else
        echo " Skipped"
    fi
}

install_gh() {
    echo -n "$(pad_output "installing gh"):"
    if command_exists gh; then
        echo " exists"
        return
    fi

    if ! confirm "Install GitHub CLI (gh)?"; then
        echo " Skipped"
        return
    fi

    if command_exists brew; then
        log_verbose "Installing gh with Homebrew"
        run_quiet brew install gh
        echo " Done"
    elif command_exists apt-get; then
        log_verbose "Installing gh with apt-get"
        if run_quiet sudo apt-get update && run_quiet sudo apt-get install -y gh; then
            echo " Done"
        else
            echo " Failed"
            echo "Error: GitHub CLI installation via apt-get failed."
            echo "Try again manually with:"
            echo "  sudo apt-get update && sudo apt-get install -y gh"
            exit 1
        fi
    elif command_exists dnf; then
        log_verbose "Installing gh with dnf"
        if run_quiet sudo dnf install -y gh; then
            echo " Done"
        else
            echo " Failed"
            echo "Error: GitHub CLI installation via dnf failed."
            echo "Try again manually with:"
            echo "  sudo dnf install -y gh"
            exit 1
        fi
    elif command_exists yum; then
        log_verbose "Installing gh with yum"
        if run_quiet sudo yum install -y gh; then
            echo " Done"
        else
            echo " Failed"
            echo "Error: GitHub CLI installation via yum failed."
            echo "Try again manually with:"
            echo "  sudo yum install -y gh"
            exit 1
        fi
    elif command_exists winget; then
        log_verbose "Installing gh with winget"
        if run_quiet winget install --id GitHub.cli -e; then
            echo " Done"
        else
            echo " Failed"
            echo "Error: GitHub CLI installation via winget failed."
            echo "Try again manually with:"
            echo "  winget install --id GitHub.cli -e"
            exit 1
        fi
    else
        echo " Failed"
        echo "Error: Could not find a supported package manager for GitHub CLI."
        echo "Install manually with one of:"
        echo "  brew install gh"
        echo "  sudo apt-get install gh"
        echo "  sudo dnf install gh"
        echo "  sudo yum install gh"
        echo "  winget install --id GitHub.cli -e"
        exit 1
    fi
}

install_claude() {
    echo -n "$(pad_output "installing claude"):"
    if command_exists claude; then
        echo " exists"
    else
        if confirm "Install Claude Code (native installer)?"; then
            log_verbose "Installing Claude Code from https://claude.ai/install.sh"
            if ! run_remote https://claude.ai/install.sh bash; then
                echo " Failed"
                echo "Error: Claude Code installation failed."
                echo "Try again manually with:"
                echo "  curl -fsSL https://claude.ai/install.sh | bash"
                exit 1
            fi
            echo " Done"
        else
            echo " Skipped"
        fi
    fi
}

install_cargo() {
    echo -n "$(pad_output "installing cargo"):"
    if command_exists cargo; then
        echo " exists"
    else
        if confirm "Install Rust (cargo) via rustup?"; then
            log_verbose "Installing rustup from https://sh.rustup.rs"
            if ! run_remote https://sh.rustup.rs sh -s -- -y --no-modify-path; then
                echo " Failed"
                echo "Error: rustup installation failed."
                echo "Try again manually with:"
                echo "  curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path"
                exit 1
            fi
            echo " Done"
        else
            echo " Skipped"
        fi
    fi
}

install_platformio() {
    echo -n "$(pad_output "installing platformio"):"
    if command_exists pio || command_exists pio.exe; then
        echo " exists"
        return
    fi

    if ! confirm "Install PlatformIO Core?"; then
        echo " Skipped"
        return
    fi

    if ! command_exists python3; then
        echo " Failed"
        echo "Error: python3 is required to install PlatformIO Core."
        exit 1
    fi

    local installer
    installer=$(mktemp "${TMPDIR:-/tmp}/get-platformio.XXXXXX.py")

    if curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py \
        -o "$installer"; then
        if run_quiet python3 "$installer"; then
            rm -f "$installer"
            echo " Done"
        else
            rm -f "$installer"
            echo " Failed"
            echo "Error: PlatformIO Core installation failed."
            echo "Try again manually with:"
            echo "  curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py -o /tmp/get-platformio.py"
            echo "  python3 /tmp/get-platformio.py"
            exit 1
        fi
    else
        rm -f "$installer"
        echo " Failed"
        echo "Error: Failed to download PlatformIO installer."
        echo "Try again manually with:"
        echo "  curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py -o /tmp/get-platformio.py"
        echo "  python3 /tmp/get-platformio.py"
        exit 1
    fi
}

install_opencode() {
    echo -n "$(pad_output "installing opencode"):"
    if command_exists opencode; then
        echo " exists"
    else
        if confirm "Install opencode (AI coding assistant)?"; then
            log_verbose "Installing opencode from https://opencode.ai/install"
            if ! run_remote https://opencode.ai/install bash; then
                echo " Failed"
                echo "Error: opencode installation failed."
                echo "Try again manually with:"
                echo "  curl -fsSL https://opencode.ai/install | bash"
                exit 1
            fi
            echo " Done"
        else
            echo " Skipped"
        fi
    fi
}

# ---------------------------------------------------------------------------
check_dependencies

echo "Bootstrapping optional developer tools ..."
log_verbose "Install prefix: $INSTALL_PREFIX"
echo ""

install_oh_my_zsh
install_mise
install_node
install_gh
install_claude
install_cargo
install_platformio
install_opencode

echo ""
echo "Bootstrap complete!"
echo "The shell profile will pick these up in a new session."
