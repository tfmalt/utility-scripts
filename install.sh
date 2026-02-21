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

# Function to initialize git submodules
init_submodules() {
    local submodule_path="$1"
    local submodule_name="$2"
    
    if [ ! -d "$submodule_path" ] || [ -z "$(ls -A "$submodule_path" 2>/dev/null)" ]; then
        log_verbose "Initializing submodule: $submodule_name"
        if [ "$VERBOSE" = true ]; then
            git submodule update --init --recursive "$submodule_path"
        else
            git submodule update --init --recursive "$submodule_path" > /dev/null 2>&1
        fi
        return 0
    else
        log_verbose "Submodule already initialized: $submodule_name"
        return 1
    fi
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
    
    echo "Uninstall complete. Oh My Zsh, cargo/rustup, platformio, mise, opencode, and claude installations were left intact."
    echo "To remove them manually:"
    echo "  rm -rf $ZSH"
    echo "  rm -rf $HOME/.cargo"
    echo "  rm -rf $HOME/.rustup"
    echo "  rm -rf $HOME/.platformio"
    echo "  rm -rf $INSTALL_PREFIX/.local/share/mise"
    echo "  rm -f $INSTALL_PREFIX/.local/bin/mise"
    echo "  rm -rf $INSTALL_PREFIX/.opencode"
    echo "  rm -f $HOME/.local/bin/claude"
    echo "  rm -rf $HOME/.local/share/claude"
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
    # Try submodule first; if it doesn't populate the repo, fall back to direct clone
    git submodule update --init --recursive "$COLORSCHEME_DIR" > /dev/null 2>&1 || true
    if [ ! -d "$COLORSCHEME_DIR/.git" ]; then
        log_verbose "Submodule init did not populate repo; cloning directly"
        if [ "$VERBOSE" = true ]; then
            git clone "$COLORSCHEME_REPO" "$COLORSCHEME_DIR"
        else
            git clone -q "$COLORSCHEME_REPO" "$COLORSCHEME_DIR"
        fi
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
                --depth=1 https://github.com/ohmyzsh/ohmyzsh.git "$ZSH" > /dev/null 2>&1
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
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM"/themes/powerlevel10k
        else
            git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM"/themes/powerlevel10k > /dev/null 2>&1
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

OUTPUT="installing mise"
echo -n "$(pad_output "$OUTPUT"):"
if command_exists mise; then
    log_verbose "mise already installed"
    echo " exists"
else
    if confirm "Install mise (polyglot runtime manager)?"; then
        log_verbose "Installing mise from https://mise.run"
        if [ "$VERBOSE" = true ]; then
            curl https://mise.run | sh
        else
            curl -sSL https://mise.run | sh
        fi
        echo " Done"
    else
        echo " Skipped"
    fi
fi

MISE_CMD=""
if command_exists mise; then
    MISE_CMD=$(command -v mise)
elif [ -x "$INSTALL_PREFIX/.local/bin/mise" ]; then
    MISE_CMD="$INSTALL_PREFIX/.local/bin/mise"
fi

OUTPUT="installing node"
echo -n "$(pad_output "$OUTPUT"):"
if command_exists node; then
    log_verbose "node already installed"
    echo " exists"
elif [ -n "$MISE_CMD" ]; then
    if confirm "Install Node.js (node@latest) via mise globally?"; then
        log_verbose "Installing node@latest via mise ($MISE_CMD)"
        if [ "$VERBOSE" = true ]; then
            if "$MISE_CMD" use -g node@latest; then
                :
            else
                echo " Failed"
                echo "Error: Node.js installation via mise failed."
                echo "Try again manually with:"
                echo "  $MISE_CMD use -g node@latest"
                exit 1
            fi
        else
            if "$MISE_CMD" use -g node@latest > /dev/null 2>&1; then
                :
            else
                echo " Failed"
                echo "Error: Node.js installation via mise failed."
                echo "Try again manually with:"
                echo "  $MISE_CMD use -g node@latest"
                exit 1
            fi
        fi

        if [ -d "$INSTALL_PREFIX/.local/bin" ] && [[ ":$PATH:" != *":$INSTALL_PREFIX/.local/bin:"* ]]; then
            PATH="$INSTALL_PREFIX/.local/bin:$PATH"
            export PATH
        fi

        eval "$("$MISE_CMD" activate bash)"
        echo " Done"
    else
        echo " Skipped"
    fi
else
    echo " Skipped"
    echo "Error: mise is required to install Node.js. Install mise first."
fi

OUTPUT="installing claude"
echo -n "$(pad_output "$OUTPUT"):"
if command_exists claude; then
    log_verbose "claude already installed"
    echo " exists"
else
    if confirm "Install Claude Code (native installer)?"; then
        log_verbose "Installing Claude Code from https://claude.ai/install.sh"
        if [ "$VERBOSE" = true ]; then
            if curl -fsSL https://claude.ai/install.sh | bash; then
                echo " Done"
            else
                echo " Failed"
                echo "Error: Claude Code installation failed."
                echo "Try again manually with:"
                echo "  curl -fsSL https://claude.ai/install.sh | bash"
                exit 1
            fi
        else
            if curl -fsSL https://claude.ai/install.sh | bash > /dev/null 2>&1; then
                echo " Done"
            else
                echo " Failed"
                echo "Error: Claude Code installation failed."
                echo "Try again manually with:"
                echo "  curl -fsSL https://claude.ai/install.sh | bash"
                exit 1
            fi
        fi
    else
        echo " Skipped"
    fi
fi

OUTPUT="installing cargo"
echo -n "$(pad_output "$OUTPUT"):"
if command_exists cargo; then
    log_verbose "cargo already installed"
    echo " exists"
else
    if confirm "Install Rust (cargo) via rustup?"; then
        log_verbose "Installing rustup from https://sh.rustup.rs"
        if curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path; then
            echo " Done"
        else
            echo " Failed"
            echo "Error: rustup installation failed."
            echo "Try again manually with:"
            echo "  curl -fsSL https://sh.rustup.rs | sh -s -- -y --no-modify-path"
            exit 1
        fi
    else
        echo " Skipped"
    fi
fi

OUTPUT="installing platformio"
echo -n "$(pad_output "$OUTPUT"):"
if command_exists pio || command_exists pio.exe; then
    log_verbose "platformio already installed"
    echo " exists"
else
    if confirm "Install PlatformIO Core?"; then
        if command_exists python3; then
            log_verbose "Installing PlatformIO Core from official installer"
            PLATFORMIO_INSTALLER=$(mktemp "${TMPDIR:-/tmp}/get-platformio.XXXXXX.py")

            if curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py \
                -o "$PLATFORMIO_INSTALLER"; then
                if python3 "$PLATFORMIO_INSTALLER"; then
                    rm -f "$PLATFORMIO_INSTALLER"
                    echo " Done"
                else
                    rm -f "$PLATFORMIO_INSTALLER"
                    echo " Failed"
                    echo "Error: PlatformIO Core installation failed."
                    echo "Try again manually with:"
                    echo "  curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py -o /tmp/get-platformio.py"
                    echo "  python3 /tmp/get-platformio.py"
                    exit 1
                fi
            else
                rm -f "$PLATFORMIO_INSTALLER"
                echo " Failed"
                echo "Error: Failed to download PlatformIO installer."
                echo "Try again manually with:"
                echo "  curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py -o /tmp/get-platformio.py"
                echo "  python3 /tmp/get-platformio.py"
                exit 1
            fi
        else
            echo " Failed"
            echo "Error: python3 is required to install PlatformIO Core."
            exit 1
        fi
    else
        echo " Skipped"
    fi
fi

OUTPUT="installing opencode"
echo -n "$(pad_output "$OUTPUT"):"
if command_exists opencode; then
    log_verbose "opencode already installed"
    echo " exists"
else
    if confirm "Install opencode (AI coding assistant)?"; then
        log_verbose "Installing opencode from https://opencode.ai/install"
        if [ "$VERBOSE" = true ]; then
            curl -fsSL https://opencode.ai/install | bash
        else
            curl -fsSL https://opencode.ai/install | bash
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
# managed-by: utility-scripts-install
export PROFILE="$PROFILE"
source \$PROFILE/zshrc.sh
EOD

OUTPUT=""
echo "Installation complete!"
echo "--------------------------------------------------------------------------------"

# Check for Cloudflare credentials
CLOUDFLARE_CREDS="$INSTALL_PREFIX/.config/cloudflare/credentials"
if [ ! -f "$CLOUDFLARE_CREDS" ]; then
    if command -v flarectl &> /dev/null; then
        echo ""
        echo "Note: flarectl is installed but Cloudflare credentials not found."
        echo ""
        echo "To configure Cloudflare API integration:"
        echo "  1. Create the directory: mkdir -p ~/.config/cloudflare"
        echo "  2. Create credentials file: touch ~/.config/cloudflare/credentials"
        echo "  3. Set secure permissions: chmod 600 ~/.config/cloudflare/credentials"
        echo "  4. Add your token: echo 'export CF_API_TOKEN=your_token_here' > ~/.config/cloudflare/credentials"
        echo ""
        echo "See README.md for detailed instructions on creating a Cloudflare API token."
        echo "--------------------------------------------------------------------------------"
    fi
else
    # Verify permissions
    PERM=$(stat -f '%A' "$CLOUDFLARE_CREDS" 2>/dev/null || stat -c '%a' "$CLOUDFLARE_CREDS" 2>/dev/null)
    if [ "$PERM" != "600" ]; then
        echo ""
        echo "Warning: Cloudflare credentials file has insecure permissions ($PERM)"
        echo "  Run: chmod 600 $CLOUDFLARE_CREDS"
        echo "--------------------------------------------------------------------------------"
    fi
fi

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
