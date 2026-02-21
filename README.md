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
| `git` | Version control, submodules | Pre-installed on most systems |
| `curl` | Downloading dependencies | Pre-installed on most systems |
| `zsh` | Default shell | `brew install zsh` / `apt install zsh` |

### Optional Tools

| Tool | Purpose | Install |
|------|---------|---------|
| `shellcheck` | Linting shell scripts | `brew install shellcheck` / `apt install shellcheck` |
| `cargo` | Rust package manager and tooling | `curl -fsSL https://sh.rustup.rs \| sh -s -- -y --no-modify-path` |
| `flarectl` | Cloudflare DNS management | `brew install cloudflare/cloudflare/flarectl` |
| `systemd` | Timer-based script execution | Linux only (not available on macOS) |

### Platform Differences

- **GNU vs BSD utilities**: macOS uses BSD versions of `sed`, `awk`, `grep`. Scripts are written to be compatible with both where possible.
- **systemd**: The `systemd/` directory contains Linux-only service files. On macOS, use `launchd` or cron instead.
- **Homebrew paths**: macOS with Apple Silicon uses `/opt/homebrew`, Intel Macs use `/usr/local`.

## Optional Configuration

### Cloudflare API Integration

If you use [flarectl](https://github.com/cloudflare/cloudflare-go/tree/master/cmd/flarectl) to manage Cloudflare DNS records, you can configure your API token to be automatically loaded.

**Setup:**

1. Create the configuration directory:

   ```bash
   mkdir -p ~/.config/cloudflare
   ```

2. Create and secure the credentials file:

   ```bash
   touch ~/.config/cloudflare/credentials
   chmod 600 ~/.config/cloudflare/credentials
   ```

3. Add your Cloudflare API token to the file:

   ```bash
   echo "export CF_API_TOKEN=your_token_here" > ~/.config/cloudflare/credentials
   ```

4. Reload your shell or source your configuration:

   ```bash
   source ~/.zshrc
   ```

The `CF_API_TOKEN` environment variable will be automatically loaded and exported when you start a new shell session. The configuration script will verify file permissions and warn you if the credentials file is not secure (should be `600`).

**Creating a Cloudflare API Token:**

1. Log in to the [Cloudflare Dashboard](https://dash.cloudflare.com/)
2. Go to **My Profile** → **API Tokens**
3. Click **Create Token**
4. Use the "Edit zone DNS" template or create a custom token with the following permissions:
   - Zone → DNS → Edit
   - Zone → Zone → Read
5. Select the specific zones you want to manage
6. Create the token and copy it to your credentials file

The install script will check for the credentials file and provide setup instructions if it's not found.

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
