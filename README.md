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

This will create symbolic links in your home directory to the files in this repository. You can also specify a different target directory with the `-d` option.

```bash
./install.sh -d /path/to/target
```

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

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Contributing

If you find anything useful in this repository, feel free to use it or contribute to it. If you encounter any bugs or have any suggestions, please open an issue or a pull request.
