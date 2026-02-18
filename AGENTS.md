# Repository Guidelines

## Project Structure & Module Organization
This repo is a collection of shell-focused utilities and dotfiles.

- `scripts/`: standalone utility scripts (bash/sh). Example: `scripts/cloudflare-ddns.sh`.
- `dotfiles/`: shell, editor, and tool configs intended to be symlinked into `$HOME`.
- `config/`: supplemental config files (e.g., `config/inputrc`, `config/eslintrc.json`).
- `systemd/`: unit/timer files (e.g., `systemd/cloudflare-ddns.service`).
- `install.sh`: installer that symlinks dotfiles/config into the target prefix.

## Build, Test, and Development Commands
- `./install.sh`: install dotfiles/config into `$HOME` (or `INSTALL_PREFIX`).
- `./install.sh -u`: uninstall and restore backups.
- `npm install`: install optional CLI dependencies used by some scripts.
- `./scripts/lint.sh`: run `shellcheck` across repository shell scripts.

## Coding Style & Naming Conventions
- Shell scripts use bash (`#!/bin/bash`), with `set -e` where appropriate.
- Indentation is 4 spaces in scripts; keep consistent with surrounding files.
- File naming favors lowercase with hyphens, e.g., `cloudflare-ddns.sh`.
- Run `shellcheck` (via `./scripts/lint.sh`) before submitting changes.

## Testing Guidelines
- Primary check is `shellcheck`. There is no separate unit test framework.
- If you add new scripts, ensure they are picked up by `./scripts/lint.sh`.
- Prefer small, focused scripts and add usage examples in comments if helpful.

## Commit & Pull Request Guidelines
- Commit messages are short, imperative, and lowercase (e.g., "fix ssh-agent issue").
- PRs should include a concise summary, the affected paths, and any setup steps.
- If changes affect installation behavior, note new env vars or flags.
- For config or credential-related changes, include safety notes (permissions, paths).

## PR Checklist

Before submitting a pull request, verify the following:

- [ ] `./scripts/lint.sh` passes without errors
- [ ] Tested `./install.sh` on a clean environment (if installation changes)
- [ ] Tested `./install.sh -u` restores previous state (if installation changes)
- [ ] Added/updated usage notes for new scripts in `scripts/README.md`
- [ ] Noted any OS-specific constraints (macOS vs Linux, GNU vs BSD tools)
- [ ] No secrets or credentials committed (check `.gitignore` coverage)
- [ ] New shell scripts have `#!/bin/bash` shebang and `# shellcheck shell=bash` directive

## Security & Configuration Tips
- Cloudflare integration expects `~/.config/cloudflare/credentials` with `600` perms.
- Avoid committing secrets; prefer environment variables and local config files.
