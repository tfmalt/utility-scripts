#!/bin/bash
set -e

# Parse command line arguments
VERBOSE=false
UNINSTALL=false
CUSTOM_DOTFILES_DIR=""
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
        --dotfiles-dir)
            CUSTOM_DOTFILES_DIR="$2"
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
            echo "  -u, --uninstall       Remove dotfiles setup and restore backups"
            echo "  --dotfiles-dir DIR    Use custom dotfiles directory (default: script_dir/dotfiles)"
            echo "  --config-dir DIR      Use custom config directory (default: script_dir/config)"
            echo "  -y, --yes             Skip confirmation prompts (assume yes)"
            echo "  -h, --help            Show this help message"
            echo ""
            echo "Environment variables:"
            echo "  DOTFILES_ROOT         Override dotfiles directory"
            echo "  CONFIG_ROOT           Override config directory"
            echo "  INSTALL_PREFIX        Override installation prefix (default: \$HOME)"
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

# Installation prefix (where dotfiles will be installed)
INSTALL_PREFIX="${INSTALL_PREFIX:-$HOME}"

# Dotfiles directory
if [ -n "$CUSTOM_DOTFILES_DIR" ]; then
    DOTFILES="$CUSTOM_DOTFILES_DIR"
elif [ -n "$DOTFILES_ROOT" ]; then
    DOTFILES="$DOTFILES_ROOT"
else
    DOTFILES="$ROOT/dotfiles"
fi

# Config directory
if [ -n "$CUSTOM_CONFIG_DIR" ]; then
    CONFIG="$CUSTOM_CONFIG_DIR"
elif [ -n "$CONFIG_ROOT" ]; then
    CONFIG="$CONFIG_ROOT"
else
    CONFIG="$ROOT/config"
fi

# Oh My Zsh paths
ZSH="$INSTALL_PREFIX/.oh-my-zsh"
ZSH_CUSTOM="$ZSH/custom"

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
        local backup="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        log_verbose "Creating backup: $file -> $backup"
        cp -r "$file" "$backup"
        echo "  backed up to: $backup"
    fi
}

# Function to restore latest backup
restore_backup() {
    local file="$1"
    local latest_backup=$(ls -t "${file}.backup."* 2>/dev/null | head -n1)
    if [ -n "$latest_backup" ]; then
        log_verbose "Restoring backup: $latest_backup -> $file"
        rm -rf "$file"
        mv "$latest_backup" "$file"
        echo "  restored from: $latest_backup"
    fi
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
        local current_target=$(readlink "$target")
        if [ "$current_target" = "$source" ]; then
            log_verbose "Symlink already correct: $target -> $source"
            echo "  already linked correctly"
            return 0
        else
            log_verbose "Updating symlink: $target ($current_target -> $source)"
            rm "$target"
        fi
    elif [ -e "$target" ]; then
        log_verbose "Target exists as regular file/directory: $target"
        echo "  exists as regular file"
        return 1
    fi
    
    log_verbose "Creating symlink: $source -> $target"
    ln -s "$source" "$target"
    echo "  created: $target_name"
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
    if [ ! -d "$DOTFILES" ]; then
        echo "Error: Dotfiles directory does not exist: $DOTFILES"
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
    echo "Uninstalling dotfiles setup..."
    log_verbose "Starting uninstall process"
    
    if ! confirm "This will remove dotfile symlinks and restore backups. Continue?"; then
        echo "Uninstall cancelled."
        exit 0
    fi
    
    OUTPUT="removing dircolors"
    echo -n "$(pad_output "$OUTPUT"):"
    remove_symlink "$INSTALL_PREFIX/.dircolors"
    restore_backup "$INSTALL_PREFIX/.dircolors"
    echo " Done"
    
    OUTPUT="removing vim setup"
    echo -n "$(pad_output "$OUTPUT"):"
    remove_symlink "$INSTALL_PREFIX/.vimrc"
    remove_symlink "$INSTALL_PREFIX/.vim"
    restore_backup "$INSTALL_PREFIX/.vimrc"
    restore_backup "$INSTALL_PREFIX/.vim"
    echo " Done"
    
    OUTPUT="removing zshrc"
    echo -n "$(pad_output "$OUTPUT"):"
    restore_backup "$INSTALL_PREFIX/.zshrc"
    echo " Done"
    
    echo "Uninstall complete. Oh My Zsh and Volta installations were left intact."
    echo "To remove them manually:"
    echo "  rm -rf $ZSH"
    echo "  rm -rf $INSTALL_PREFIX/.volta"
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
OUTPUT="dotfiles directory"
echo "$(pad_output "$OUTPUT"): $DOTFILES"
OUTPUT="config directory"
echo "$(pad_output "$OUTPUT"): $CONFIG"
OUTPUT="destination"
echo "$(pad_output "$OUTPUT"): $INSTALL_PREFIX"

# Ask for confirmation before proceeding
echo ""
if ! confirm "Proceed with dotfiles installation?"; then
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
create_symlink "$DOTFILES/vimrc" "$INSTALL_PREFIX/.vimrc" ".vimrc"
create_symlink "$DOTFILES/vim" "$INSTALL_PREFIX/.vim" ".vim"
echo ""
# ---------------------------------------------------------------------------
OUTPUT="installing oh my zsh"
echo -n "$(pad_output "$OUTPUT"):"

if [ ! -d "$ZSH" ]; then
    if confirm "Install Oh My Zsh?"; then
        log_verbose "Cloning Oh My Zsh repository to $ZSH"
        if [ "$VERBOSE" = true ]; then
            git clone -c core.eol=lf -c core.autocrlf=false \
                -c fsck.zeroPaddedFilemode=ignore \
                -c fetch.fsck.zeroPaddedFilemode=ignore \
                -c receive.fsck.zeroPaddedFilemode=ignore \
                --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH"
        else
            git clone -c core.eol=lf -c core.autocrlf=false \
                -c fsck.zeroPaddedFilemode=ignore \
                -c fetch.fsck.zeroPaddedFilemode=ignore \
                -c receive.fsck.zeroPaddedFilemode=ignore \
                --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH" 2>&1 > /dev/null
        fi
        echo " Done"
    else
        echo " Skipped"
    fi
else
    log_verbose "Oh My Zsh already exists at $ZSH"
    echo " exists"
fi

# ---------------------------------------------------------------------------
OUTPUT="installing p10k theme"
echo -n "$(pad_output "$OUTPUT"):" 

if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    if [ -d "$ZSH" ] && confirm "Install Powerlevel10k theme?"; then
        log_verbose "Cloning Powerlevel10k theme to $ZSH_CUSTOM/themes/powerlevel10k"
        if [ "$VERBOSE" = true ]; then
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k
        else
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k 2>&1 > /dev/null 
        fi
        echo " Done"
    else
        echo " Skipped"
    fi
else 
    log_verbose "Powerlevel10k theme already exists"
    echo " exists"
fi
# ---------------------------------------------------------------------------

OUTPUT="installing volta"
echo -n "$(pad_output "$OUTPUT"):" 
if [ -e "$INSTALL_PREFIX/.volta" ]; then
    log_verbose "Volta already installed at $INSTALL_PREFIX/.volta"
    echo " exists"
else 
    if confirm "Install Volta (Node.js version manager)?"; then
        log_verbose "Installing Volta from https://get.volta.sh"
        if [ "$VERBOSE" = true ]; then
            VOLTA_HOME="$INSTALL_PREFIX/.volta" curl https://get.volta.sh | bash -s -- --skip-setup
        else
            VOLTA_HOME="$INSTALL_PREFIX/.volta" curl -s https://get.volta.sh | bash -s -- --skip-setup
        fi
        echo " Done"
    else
        echo " Skipped"
    fi
fi

OUTPUT="writing"
FILE="$INSTALL_PREFIX/.zshrc"
echo "$(pad_output "$OUTPUT"): $FILE"
backup_file "$FILE"
log_verbose "Writing new .zshrc configuration"

cat > "$FILE" <<- EOD
export DOTFILES="$DOTFILES"
source \$DOTFILES/zshrc.sh
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
    echo "Note: .zshrc was not created. Please restart your terminal to use the new dotfiles."
fi
