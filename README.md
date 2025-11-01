# Utility Scripts

This repository contains a collection of utility scripts that might be
useful to others. They are mainly focused on unix/posix shells and command
line tools.

## Features

- **dotfiles**: personal configuration files for zsh, tmux, vim and other tools
- **scripts**: various scripts to make work easier, such as backup, git, ssh and more
- **config**: additional configuration files for tools like git and ssh

## Installation

To install the scripts and dotfiles, run the following command:

```bash
./install.sh
```

This will create symbolic links in your home directory to the files in this repository.

### Installation Options

```bash
./install.sh [OPTIONS]

Options:
  -v, --verbose           Enable verbose output for debugging
  -u, --uninstall         Remove dotfiles setup and restore backups
  -y, --yes               Skip confirmation prompts (assume yes)
  --dotfiles-dir DIR      Use custom dotfiles directory
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
./install.sh --dotfiles-dir /path/to/dotfiles --config-dir /path/to/config

# Uninstall and restore backups
./install.sh -u
```

### Environment Variables

You can also control installation using environment variables:

- `DOTFILES_ROOT`: Override dotfiles directory
- `CONFIG_ROOT`: Override config directory
- `INSTALL_PREFIX`: Override installation target (default: `$HOME`)

## Dependencies

Some of the scripts and dotfiles depend on external tools or modules.
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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

If you find anything useful in this repository, feel free to use it or contribute to it. If you encounter any bugs or have any suggestions, please open an issue or a pull request.
