# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a comprehensive profile management system that provides a complete Unix/POSIX shell environment setup. The project manages configuration files for zsh, vim, tmux, and various development tools using a symlink-based installation approach with comprehensive backup and restore capabilities.

## Essential Commands

### Installation and Management

```bash
./install.sh                    # Interactive installation with prompts
./install.sh -v                 # Verbose mode with detailed logging
./install.sh -y                 # Skip all confirmation prompts
./install.sh -u                 # Uninstall mode - removes symlinks and restores backups
./install.sh --profile-dir DIR  # Use custom profile directory
./install.sh --help             # Show all available options
```

### Dependencies

```bash
npm install  # Install git utilities (git-open, git-recent, git-extras, etc.)
git submodule update --init --recursive  # Initialize vim colorscheme submodule
```

## Architecture Overview

### Modular Configuration System

The shell configuration uses a numbered loading system in `profile/sh_config.d/`:

- `01-09`: Bootstrap — helper functions and early init (icons, p10k instant prompt)
- `10-19`: Foundation — environment variables, locales, core tool setup (zoxide, fzf, completions, Oh My Zsh)
- `20-29`: Display — colors, dircolors
- `30-39`: Dev tools — language-specific version managers and toolchains (cargo, gcloud, platformio, fnm)
- `40-49`: Auth & credentials — SSH agent, API tokens (Homebrew, Cloudflare, AWS)
- `90-99`: Finalization — aliases, shell-specific config, prompts, plugins, last-mile setup

Files use a `NN.descriptive-name.sh` naming convention with kebab-case for multi-word names. Each prefix number must be unique.

### Key Components

**`install.sh`**: Sophisticated installation script with:

- Symlink creation with collision detection
- Comprehensive backup system with timestamped backups
- Uninstall capability with backup restoration
- Dependency checking and installation (Oh My Zsh, Powerlevel10k, fnm)
- Cross-platform support with verbose logging

**`profile/sh_functions.d/setuptype.bash`**: System detection function that identifies:

- Linux variants (server, virtual, WSL, Raspberry Pi)
- macOS systems
- Container environments (LXC)
- Used throughout configuration for conditional behavior

**`profile/zshrc.sh`**: Main configuration loader that:

- Sources all modular configurations in order
- Handles function pre-loading
- Provides fallback for missing components

### Configuration Flow

1. `~/.zshrc` → `$PROFILE/zshrc.sh` (entry point)
2. Load `sh_functions.d/*.bash` (system utilities)
3. Source `sh_config.d/*.sh` in numerical order (modular config)
4. Apply platform-specific configurations based on `setuptype()`

## Development Patterns

### Adding New Configurations

- Place shell configs in `profile/sh_config.d/` with appropriate number prefix
- Use `setuptype()` function for platform-specific logic
- Add functions to `profile/sh_functions.d/` for reusable utilities

### Modifying install.sh

- Maintain existing pattern of padded output and confirmation prompts
- Use `log_verbose()` for debug information
- Follow backup/restore pattern for any new file operations
- Test both verbose and quiet modes

### Working with Submodules

- Vim colorschemes are managed as git submodule in `profile/vim/awesome-vim-colorschemes`
- Use `git config submodule.profile/vim/awesome-vim-colorschemes.ignore all` to ignore changes
- Install script automatically initializes submodules during setup

## Testing Approach

Since this is a profile repository, testing primarily involves:

- Running `./install.sh -v` in a clean environment
- Verifying symlinks are created correctly in `$HOME`
- Testing uninstall with `./install.sh -u` restores backups
- Checking cross-platform compatibility with `setuptype()` detection
- Validating modular loading by sourcing individual config files

## Important Notes

- All user files are backed up before symlinking (format: `file.backup.YYYYMMDD_HHMMSS`)
- Configuration supports multiple shell environments (bash/zsh) with shared components
- System type detection drives conditional configuration loading
- The project follows semantic versioning (see package.json)
- Installation requires git and curl as dependencies
