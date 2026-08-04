#!/bin/bash
set -e

# Parse command line arguments
VERBOSE=false
UNINSTALL=false
CUSTOM_PROFILE_DIR=""
CUSTOM_CONFIG_DIR=""
SKIP_CONFIRM=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -v|--verbose)
            VERBOSE=true
            shift
            ;;
        -u|--uninstall)
            UNINSTALL=true
            shift
            ;;
        --profile-dir)
            CUSTOM_PROFILE_DIR="$2"
            shift 2
            ;;
        --config-dir)
            CUSTOM_CONFIG_DIR="$2"
            shift 2
            ;;
        -y|--yes)
            SKIP_CONFIRM=true
            shift
            ;;
        -h|--help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  -v, --verbose         Enable verbose output"
            echo "  -u, --uninstall       Remove profile setup and restore backups"
            echo "  --profile-dir DIR     Use custom profile directory (default: script_dir/profile)"
            echo "  --config-dir DIR      Use custom config directory (default: script_dir/config)"
            echo "  -y, --yes             Skip confirmation prompts (assume yes)"
            echo "  -h, --help            Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  PROFILE_ROOT          Override profile directory"
            echo "  CONFIG_ROOT           Override config directory"
            echo "  INSTALL_PREFIX        Override installation prefix (default: \$HOME)"
            echo ""
            echo "This script only manages symlinks, backups, and the .zshrc entry point."
            echo "Optional developer tools are installed separately:"
            echo "  ./scripts/bootstrap.sh"
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# Set up paths with priority: command line > environment > defaults
THIS=$(readlink -f "$0")
ROOT=$(dirname "$THIS")

# Installation prefix (where profile files will be installed)
INSTALL_PREFIX="${INSTALL_PREFIX:-$HOME}"

# Profile directory
if [ -n "$CUSTOM_PROFILE_DIR" ]; then
    PROFILE="$CUSTOM_PROFILE_DIR"
elif [ -n "$PROFILE_ROOT" ]; then
    PROFILE="$PROFILE_ROOT"
else
    PROFILE="$ROOT/profile"
fi

# Config directory
if [ -n "$CUSTOM_CONFIG_DIR" ]; then
    CONFIG="$CUSTOM_CONFIG_DIR"
elif [ -n "$CONFIG_ROOT" ]; then
    CONFIG="$CONFIG_ROOT"
else
    CONFIG="$ROOT/config"
fi

PAD=24

# Function to pad output text
pad_output() {
    printf "%-${PAD}s" "$1"
}

# Function for verbose logging
log_verbose() {
    if [ "$VERBOSE" = true ]; then
        echo "  [VERBOSE] $1"
    fi
}

# Function to backup existing files
backup_file() {
    local file="$1"
    if [ -e "$file" ] && [ ! -L "$file" ]; then
        local backup
        backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_verbose "Creating backup: $file -> $backup"
        cp -r "$file" "$backup"
        echo "  backed up to: $backup"
    fi
}

# Function to restore latest backup
restore_backup() {
    local file="$1"
    local latest_backup=""
    local backup
    for backup in "${file}.backup."*; do
        if [ -e "$backup" ]; then
            latest_backup="$backup"
        fi
    done
    if [ -n "$latest_backup" ]; then
        log_verbose "Restoring backup: $latest_backup -> $file"
        rm -rf "$file"
        mv "$latest_backup" "$file"
        echo "  restored from: $latest_backup"
        return 0
    fi

    return 1
}

# Function to remove symlink if it exists
remove_symlink() {
    local file="$1"
    if [ -L "$file" ]; then
        log_verbose "Removing symlink: $file"
        rm "$file"
        echo "  removed symlink: $file"
    fi
}

# Function to create symlink safely
create_symlink() {
    local source="$1"
    local target="$2"
    local target_name="$3"
    
    if [ -L "$target" ]; then
        local current_target
        current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            log_verbose "Symlink already correct: $target -> $source"
            echo "  already linked correctly"
            return 0
        else
            log_verbose "Updating symlink: $target ($current_target -> $source)"
            rm "$target"
        fi
    elif [ -e "$target" ]; then
        log_verbose "Replacing existing regular file/directory: $target"
        rm -rf "$target"
    fi
    
    log_verbose "Creating symlink: $source -> $target"
    ln -s "$source" "$target"
    echo "  created: $target_name"
}

# Function to check whether .zshrc is managed by this installer
is_managed_zshrc() {
    local file="$1"

    [ -f "$file" ] || return 1

    if grep -q "^# managed-by: utility-scripts-install$" "$file"; then
        return 0
    fi

    # Backward compatibility with the previous unmanaged template
    if grep -q '^export PROFILE=' "$file" \
        && grep -q "^source \\\$PROFILE/zshrc.sh$" "$file"; then
        return 0
    fi

    return 1
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check dependencies
check_dependencies() {
    local missing_deps=()
    
    if ! command_exists git; then
        missing_deps+=("git")
    fi
    
    if ! command_exists curl; then
        missing_deps+=("curl")
    fi
    
    if [ ${#missing_deps[@]} -gt 0 ]; then
        echo "Error: Missing required dependencies: ${missing_deps[*]}"
        echo "Please install the missing tools and try again."
        echo ""
        echo "On Ubuntu/Debian: sudo apt-get install ${missing_deps[*]}"
        echo "On CentOS/RHEL: sudo yum install ${missing_deps[*]}"
        echo "On macOS: brew install ${missing_deps[*]}"
        exit 1
    fi
    
    log_verbose "All dependencies available: git, curl"
}

# Function to ask for confirmation
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

# Function to validate paths exist
validate_paths() {
    if [ ! -d "$PROFILE" ]; then
        echo "Error: Profile directory does not exist: $PROFILE"
        exit 1
    fi
    
    if [ ! -d "$CONFIG" ]; then
        echo "Error: Config directory does not exist: $CONFIG"
        exit 1
    fi
    
    log_verbose "Path validation successful"
}

# Uninstall function
uninstall() {
    echo "Uninstalling profile setup..."
    log_verbose "Starting uninstall process"
    
    if ! confirm "This will remove dotfile symlinks and restore backups. Continue?"; then
        echo "Uninstall cancelled."
        exit 0
    fi
    
    OUTPUT="removing dircolors"
    echo -n "$(pad_output "$OUTPUT"):"
    remove_symlink "$INSTALL_PREFIX/.dircolors"
    restore_backup "$INSTALL_PREFIX/.dircolors" || true
    echo " Done"
    
    OUTPUT="removing vim setup"
    echo -n "$(pad_output "$OUTPUT"):"
    remove_symlink "$INSTALL_PREFIX/.vimrc"
    remove_symlink "$INSTALL_PREFIX/.vim"
    restore_backup "$INSTALL_PREFIX/.vimrc" || true
    restore_backup "$INSTALL_PREFIX/.vim" || true
    echo " Done"
    
    OUTPUT="removing zshrc"
    echo -n "$(pad_output "$OUTPUT"):"
    remove_symlink "$INSTALL_PREFIX/.zshrc"
    if ! restore_backup "$INSTALL_PREFIX/.zshrc"; then
        if is_managed_zshrc "$INSTALL_PREFIX/.zshrc"; then
            rm -f "$INSTALL_PREFIX/.zshrc"
            echo "  removed managed file: $INSTALL_PREFIX/.zshrc"
        fi
    fi
    echo " Done"
    
    echo "Uninstall complete. Symlinks removed and backups restored."
    echo "Optional tool installations are managed by ./scripts/bootstrap.sh and were left intact."
}

# ---------------------------------------------------------------------------
# Handle uninstall mode
if [ "$UNINSTALL" = true ]; then
    uninstall
    exit 0
fi

echo "Setting up utility scripts ..."
log_verbose "Verbose mode enabled"
log_verbose "Script location: $THIS"

# Check dependencies before proceeding
check_dependencies

# Validate paths exist
validate_paths

OUTPUT="source directory"
echo "$(pad_output "$OUTPUT"): $ROOT"
OUTPUT="profile directory"
echo "$(pad_output "$OUTPUT"): $PROFILE"
OUTPUT="config directory"
echo "$(pad_output "$OUTPUT"): $CONFIG"
OUTPUT="destination"
echo "$(pad_output "$OUTPUT"): $INSTALL_PREFIX"

# Ask for confirmation before proceeding
echo ""
if ! confirm "Proceed with profile installation?"; then
    echo "Installation cancelled."
    exit 0
fi

# ---------------------------------------------------------------------------
OUTPUT="setting up dircolors"
echo -n "$(pad_output "$OUTPUT"):"
backup_file "$INSTALL_PREFIX/.dircolors"
create_symlink "$CONFIG/dircolors" "$INSTALL_PREFIX/.dircolors" ".dircolors"

# ---------------------------------------------------------------------------
OUTPUT="setting up vim"
echo -n "$(pad_output "$OUTPUT"):"
backup_file "$INSTALL_PREFIX/.vimrc"
backup_file "$INSTALL_PREFIX/.vim"
create_symlink "$PROFILE/vimrc" "$INSTALL_PREFIX/.vimrc" ".vimrc"
create_symlink "$PROFILE/vim" "$INSTALL_PREFIX/.vim" ".vim"
echo ""

# ---------------------------------------------------------------------------
COLORSCHEME_REPO="https://github.com/rafi/awesome-vim-colorschemes.git"
COLORSCHEME_DIR="$PROFILE/vim/awesome-vim-colorschemes"
COLORSCHEME_COLORS_LINK="$PROFILE/vim/colors"

OUTPUT="initializing vim themes"
echo -n "$(pad_output "$OUTPUT"):"
if [ -d "$COLORSCHEME_DIR/.git" ]; then
    log_verbose "awesome-vim-colorschemes already present"
    echo " exists"
else
    log_verbose "Cloning awesome-vim-colorschemes from $COLORSCHEME_REPO"
    if [ "$VERBOSE" = true ]; then
        git clone "$COLORSCHEME_REPO" "$COLORSCHEME_DIR"
    else
        git clone -q "$COLORSCHEME_REPO" "$COLORSCHEME_DIR"
    fi
    echo " Done"
fi

OUTPUT="linking vim colors"
echo -n "$(pad_output "$OUTPUT"):"
if [ -L "$COLORSCHEME_COLORS_LINK" ] && [ "$(readlink "$COLORSCHEME_COLORS_LINK")" = "$COLORSCHEME_DIR/colors" ]; then
    log_verbose "vim/colors symlink already correct"
    echo " exists"
elif [ -e "$COLORSCHEME_COLORS_LINK" ] && [ ! -L "$COLORSCHEME_COLORS_LINK" ]; then
    log_verbose "vim/colors exists as real directory, skipping symlink"
    echo " exists (real dir)"
else
    ln -sf "$COLORSCHEME_DIR/colors" "$COLORSCHEME_COLORS_LINK"
    log_verbose "Created symlink: vim/colors -> awesome-vim-colorschemes/colors"
    echo " Done"
fi

# ---------------------------------------------------------------------------
OUTPUT="writing"
FILE="$INSTALL_PREFIX/.zshrc"
echo "$(pad_output "$OUTPUT"): $FILE"
backup_file "$FILE"
log_verbose "Writing new .zshrc configuration"

cat > "$FILE" <<- EOD
# managed-by: utility-scripts-install
export PROFILE="$PROFILE"
source \$PROFILE/zshrc.sh
EOD

OUTPUT=""
echo "Installation complete!"
echo "--------------------------------------------------------------------------------"

# Offer to source the new configuration
if [ -f "$INSTALL_PREFIX/.zshrc" ]; then
    echo "Your new shell configuration is ready."
    echo ""
    if confirm "Source the new .zshrc configuration now?"; then
        if [ -n "$ZSH_VERSION" ]; then
            # We're already in zsh, source the config
            log_verbose "Sourcing new .zshrc configuration"
            source "$INSTALL_PREFIX/.zshrc"
            echo "Configuration loaded successfully!"
        else
            # We're in a different shell, start zsh
            log_verbose "Starting new zsh session"
            echo "Starting new zsh session..."
            exec zsh
        fi
    else
        echo "To use your new configuration:"
        echo "  source $INSTALL_PREFIX/.zshrc"
        echo "  # OR restart your terminal"
    fi
else
    echo "Note: .zshrc was not created. Please restart your terminal to use the new profile setup."
fi

echo ""
echo "Optional developer tools are not installed by this script."
echo "To install them (oh-my-zsh, p10k, mise, node, gh, claude, cargo, platformio, opencode):"
echo "  ./scripts/bootstrap.sh"
