# Utility Scripts

This repository contains a collection of utility scripts that might be
useful to others. They are mainly focused on unix/posix shells and command
line tools.

## Features

- **profile**: personal shell/editor/terminal profile files for zsh, tmux, vim and related tools
- **scripts**: various scripts to make work easier, such as backup, git, ssh and more
- **config**: additional configuration files for tools like git and ssh

## Installation

To install the scripts and profile setup, run the following command:

```bash
./install.sh
```

This will create symbolic links in your home directory to the files in this repository.

### Installation Options

```bash
./install.sh [OPTIONS]

Options:
  -v, --verbose           Enable verbose output for debugging
  -u, --uninstall         Remove profile setup and restore backups
  -y, --yes               Skip confirmation prompts (assume yes)
  --profile-dir DIR       Use custom profile directory
  --config-dir DIR        Use custom config directory
  -h, --help              Show help message
```

### Examples

```bash
# Install with verbose output
./install.sh -v

# Install without confirmation prompts
./install.sh -y

# Install with custom directories
./install.sh --profile-dir /path/to/profile --config-dir /path/to/config

# Uninstall and restore backups
./install.sh -u
```

### Environment Variables

You can also control installation using environment variables:

- `PROFILE_ROOT`: Override profile directory
- `CONFIG_ROOT`: Override config directory
- `INSTALL_PREFIX`: Override installation target (default: `$HOME`)

**Precedence**: Command-line options (`--profile-dir`) override environment variables (`PROFILE_ROOT`), which override defaults.

### Optional Tool Installation

`install.sh` only manages symlinks, backups, and the `~/.zshrc` entry point. It does **not** install developer tools. To install the optional tools that the shell profile configures (oh-my-zsh, mise, node, gh, claude, cargo, platformio, opencode):

```bash
./scripts/bootstrap.sh     # Interactive, confirms each tool
./scripts/bootstrap.sh -y  # Skip confirmation prompts
./scripts/bootstrap.sh -v  # Verbose installer output
```


### Profile Directory (Intended Usage)

The repository directory `profile/` is the source of truth for your interactive shell environment.

- It stores modular shell config, shell functions, completions, prompt config, and related CLI UX files.
- It is intentionally named `profile` to align with UNIX/POSIX profile terminology.
- It is **not** the same thing as your local `~/.profile` file.
- The installer links target files in `$HOME` to content in this repository and writes `~/.zshrc` to source `profile/zshrc.sh`.

### Installer Behavior

#### Symlink Creation

The installer creates symbolic links in your home directory pointing to files in this repository:

```
~/.zshrc     → $PROFILE/zshrc.sh
~/.vimrc     → $PROFILE/vimrc
~/.vim       → $PROFILE/vim
~/.dircolors → $CONFIG/dircolors
```

#### Backup Strategy

Before creating symlinks, the installer backs up any existing files:

- **Backup format**: `filename.backup.YYYYMMDD_HHMMSS`
- **Example**: `~/.zshrc.backup.20250217_143022`
- Backups are created in the same directory as the original file

#### Uninstall & Recovery

To restore your original configuration:

```bash
./install.sh -u
```

This will:
1. Remove all symlinks created by the installer
2. Restore the most recent backup for each file
3. Leave additional backups intact for manual recovery

#### Interrupted Installation

If installation is interrupted:
- Partial symlinks may exist alongside backups
- Run `./install.sh -u` to clean up, then reinstall
- Backups are never deleted during normal operation

## Dependencies

Some of the scripts and profile files depend on external tools or modules.
You can install them with the following command:

```bash
npm install
```

This will install the following dependencies:

- [git-open](https://github.com/paulirish/git-open): a script to open the GitHub page or website for a repository
- [git-recent](https://github.com/paulirish/git-recent): a script to see the most recent branches you've checked out
- [git-extras](https://github.com/tj/git-extras): a set of useful git commands
- [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting): a zsh plugin that enables syntax highlighting for commands
- [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions): a zsh plugin that suggests commands based on your history

## Compatibility

### Supported Platforms

- **macOS** (primary development platform)
- **Linux** (Debian/Ubuntu, Fedora, Raspberry Pi OS)
- **WSL** (Windows Subsystem for Linux)

### Required Tools

| Tool | Purpose | Install |
|------|---------|---------|
| `git` | Version control, cloning dependencies | Pre-installed on most systems |
| `curl` | Downloading dependencies | Pre-installed on most systems |
| `zsh` | Default shell | `brew install zsh` / `apt install zsh` |
| `starship` | zsh prompt | `brew install starship` / [other platforms](https://starship.rs/installing/) |

### Optional Tools

| Tool | Purpose | Install |
|------|---------|---------|
| `shellcheck` | Linting shell scripts | `brew install shellcheck` / `apt install shellcheck` |
| `cargo` | Rust package manager and tooling | `curl -fsSL https://sh.rustup.rs \| sh -s -- -y --no-modify-path` |
| `gh` | GitHub CLI for repo/PR workflows | `brew install gh` / `apt install gh` |
| `flarectl` | Cloudflare DNS management | `brew install cloudflare/cloudflare/flarectl` |
| `systemd` | Timer-based script execution | Linux only (not available on macOS) |

### Platform Differences

- **GNU vs BSD utilities**: macOS uses BSD versions of `sed`, `awk`, `grep`. Scripts are written to be compatible with both where possible.
- **systemd**: The `systemd/` directory contains Linux-only service files. On macOS, use `launchd` or cron instead.
- **Homebrew paths**: macOS with Apple Silicon uses `/opt/homebrew`, Intel Macs use `/usr/local`.

## Optional Configuration

### Starship Prompt

Starship renders the zsh prompt while Oh My Zsh continues to provide plugins,
aliases, completion, and vi-mode behavior. The tracked configuration is
`profile/starship.toml`; `profile/sh_config.d/89.starship.sh` selects it through
`STARSHIP_CONFIG` and initializes Starship after the shell integrations.

Install Starship before starting a new zsh session:

```bash
# macOS or Linuxbrew
brew install starship

# Other supported platforms
curl -sS https://starship.rs/install.sh | sh
```

The prompt expects a Nerd Font for the OS, language, and Powerline glyphs. The
existing Bash prompt remains independent and does not require Starship.

### Truecolor Terminal Support

The shell profile enables truecolor (24-bit color) support by exporting `COLORTERM=truecolor` in `profile/sh_config.d/22.truecolor.sh`.

This helps terminal-aware tools (such as modern prompts, Vim/Neovim, and other TUI applications) detect full color capability.

### envstatus Tool Overrides (Local Only)

The `envstatus` function now supports per-user, per-host local overrides so you can disable checks for tools that are not relevant on a specific machine.

- Overrides are stored in: `${XDG_CONFIG_HOME:-$HOME/.config}/envstatus/disabled-tools.conf`
- This file is local to the current user and host
- By default, all checks remain enabled unless explicitly disabled in this file

**Commands:**

```bash
# Show environment status (default behavior)
envstatus

# Disable a tool check locally (example: linux-server)
envstatus disable platformio

# Re-enable a tool check
envstatus enable platformio

# List currently disabled tools
envstatus disabled

# Show command help
envstatus help
```

When a tool is disabled, `envstatus` shows it as `disabled via local config` and does not count it as a warning or error.

### Cloudflare Credentials

The Cloudflare DDNS scripts (`scripts/cloudflare-ddns.sh`, `scripts/install-cloudflare-ddns.sh`) read your API token from `~/.config/cloudflare/credentials`. See `scripts/README.md` for setup.

The `envstatus` shell function also checks this file and warns if its permissions are not `600`.

## Security & Credentials

### Credential Files

This profile system may source or create files containing secrets. Keep these secure:

| File | Purpose | Required Permissions |
|------|---------|---------------------|
| `~/.config/cloudflare/credentials` | Cloudflare API token | `600` |
| `~/.ssh/config` | SSH host configurations | `600` |
| `~/.ssh/id_*` | SSH private keys | `600` |
| `~/.aws/credentials` | AWS access keys | `600` |

### Permission Checks

The shell configuration includes runtime checks for credential files. If permissions are too open, you'll see warnings like:

```
WARNING: Cloudflare credentials have unsafe permissions.
Please run: chmod 600 ~/.config/cloudflare/credentials
```

### Avoiding Secret Leaks

- **Never commit credentials** to this repository
- Use environment variables or local config files for secrets
- The `.gitignore` excludes common secret patterns, but always verify before committing
- SSH keys and cloud credentials belong in `~/.ssh/` and `~/.config/`, not in this repo

### SSH Agent

The configuration automatically starts `ssh-agent` if not running and loads keys from `~/.ssh/`. Keys are cached for the session to avoid repeated passphrase prompts.

## Verification / Smoke Tests

Quick commands to verify the installation is working:

```bash
# Check that profile files are properly symlinked
ls -la ~/.zshrc ~/.vimrc ~/.vim ~/.dircolors

# Verify shell configuration loads without errors
zsh -i -c 'echo "Shell loaded successfully"'

# Verify Starship uses the tracked configuration
STARSHIP_CONFIG="$PWD/profile/starship.toml" starship explain

# Run linter on all scripts
./scripts/lint.sh

# Test system detection function
source profile/sh_functions.d/setuptype.bash && setuptype

# Verify install script help works
./install.sh --help
```

### Expected Outputs

| Command | Expected Result |
|---------|-----------------|
| `ls -la ~/.zshrc` | Symlink pointing to `profile/zshrc.sh` |
| `setuptype` | One of: `macbook`, `linux`, `linux-server`, `linux-virtual`, `linux-rpi`, `windows` |
| `./scripts/lint.sh` | "All checks passed!" with exit code 0 |

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

If you find anything useful in this repository, feel free to use it or contribute to it. If you encounter any bugs or have any suggestions, please open an issue or a pull request.
