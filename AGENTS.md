# Repository Guidelines

## Project Overview
This repository manages a personal UNIX/POSIX shell environment using symlinks.

- `profile/` is the source-of-truth for shell/editor/terminal profile files.
- `scripts/` contains standalone utility scripts.
- `config/` contains supplemental configuration files.
- `systemd/` contains service/timer units.
- `install.sh` installs/uninstalls by creating/restoring symlinks.

## Build, Lint, and Test Commands

### Setup and Installation
- `./install.sh` - interactive install into `$HOME` (or `INSTALL_PREFIX`).
- `./install.sh -v` - verbose install with debug output.
- `./install.sh -y` - skip confirmation prompts.
- `./install.sh -u` - uninstall symlinks and restore backups.
- `./install.sh --profile-dir /path/to/profile --config-dir /path/to/config` - custom roots.

### Dependencies
- `npm install` - install optional CLI dependencies.
- `git submodule update --init --recursive` - initialize vim colorscheme submodule.

### Linting (Primary Test)
- `./scripts/lint.sh` - run ShellCheck across repository shell files.
- Single file (strict): `shellcheck -s bash path/to/file.sh`.
- Single file (relaxed severity used in some profile files): `shellcheck -s bash -S error path/to/file.sh`.
- Script folder quick check: `shellcheck -s bash scripts/*.sh scripts/*.bash`.

### CI
- GitHub Actions workflow: `.github/workflows/shellcheck.yml`.
- CI runs ShellCheck for install script, profile config files, and profile functions.

## Single-Test Guidance
There is no unit test framework in this repository.

- Treat one ShellCheck invocation as a single test.
- Most useful single test during development:
  - `shellcheck -s bash install.sh`
  - `shellcheck -s bash profile/zshrc.sh`
  - `shellcheck -s bash scripts/cloudflare-ddns.sh`
  - `shellcheck -s bash -x scripts/cloudflare-ddns.sh` (verbose output)
  - `shellcheck -s bash -S error profile/sh_config.d/20.editor.sh` (relaxed severity)

## Code Style Guidelines

### Tool Installation Policy
- For profile snippets that configure developer tools, use **install guidance only**.
- Do **not** auto-install tools during shell startup.
- Snippets should detect presence, configure environment/completions when available, and print clear install commands when missing.

### Shell and Shebang
- Use `#!/bin/bash` for executable scripts.
- Add `# shellcheck shell=bash` to sourced shell fragments.
- Prefer `set -euo pipefail` in standalone scripts.
- For sourced profile snippets, avoid options that can break parent shells unless intentional.

### Formatting
- Use 4-space indentation in scripts and keep existing style per file.
- Keep line lengths readable; split long commands with `\` when needed.
- Use one logical action per block and keep sections clearly separated.

### Variables and Quoting
- Always quote expansions: `"$var"`, `"${array[@]}"`.
- Use `${var:-}` when reading optional variables under `set -u`.
- Prefer local variables inside functions: `local name="..."`.
- Use uppercase names for exported/global env vars; lowercase for local temporaries.

### Functions and Naming
- Use `snake_case` for function names.
- File names should be lowercase with hyphens for scripts (example: `cloudflare-ddns.sh`).
- Profile snippet files use numeric prefixes to control source order (example: `90.prompts.sh`).

### Imports/Sourcing
- Source paths explicitly and quote them.
- Add ShellCheck source directives when needed:
  - `# shellcheck source=/dev/null`
  - `# shellcheck disable=SC1090`
- Avoid implicit dependency on current working directory.

### Types
Shell has no static types; use predictable conventions instead:

- Booleans: `true`/`false` strings or integer checks, but keep consistent per script.
- Arrays for lists where whitespace safety matters.
- Exit codes for function outcomes (`0` success, non-zero error).

### Error Handling
- Fail fast for scripts (`set -euo pipefail` where appropriate).
- Validate dependencies early (`command -v tool >/dev/null 2>&1`).
- Provide actionable error messages including the missing command/file.
- Return non-zero on failure paths; avoid swallowing errors silently.
- Prefer helper functions like `error_exit` and centralized checks.

## Architecture and Load Order

### Profile Loader Pattern
- Entry point: generated `~/.zshrc` exports `PROFILE` and sources `profile/zshrc.sh`.
- `profile/zshrc.sh` loads:
  1) `profile/sh_functions.d/*`
  2) `profile/sh_config.d/*` in lexical/numeric order

### Numbered Config Buckets
- `01-09`: helpers/core behavior
- `10-19`: environment and shell framework
- `20-29`: display/colors
- `30-39`: developer tools
- `40-49`: auth/credentials integrations
- `90-99`: aliases/prompts/late overrides

### Key Components
- `install.sh`: backups, symlinks, uninstall restore, dependency checks.
- `profile/sh_functions.d/setuptype.bash`: platform detection and conditional logic.
- `scripts/cloudflare-ddns.sh`: production-style script using strict mode and explicit validation.

## Compatibility and Migration Notes
- Canonical names are `profile/`, `--profile-dir`, and `PROFILE_ROOT`.
- Deprecated aliases still supported for compatibility:
  - `--dotfiles-dir`
  - `DOTFILES_ROOT`
  - `$DOTFILES` (runtime alias exported by installer)
- Prefer canonical names for all new changes.

## Security and Credentials
- Never commit secrets or credential files.
- Cloudflare credentials expected at `~/.config/cloudflare/credentials` with `600` permissions.
- Keep SSH/AWS credentials outside this repo (`~/.ssh`, `~/.aws`, `~/.config`).

## PR and Review Checklist
- Run `./scripts/lint.sh` locally.
- Run targeted single-file ShellCheck on each changed script.
- If installer behavior changed, test both `./install.sh` and `./install.sh -u`.
- Update `README.md` and `scripts/README.md` when adding/changing scripts.
- Note OS-specific constraints (macOS vs Linux, GNU vs BSD tools).
- Ensure no credentials are introduced.

## Agent-Specific Instruction Sources
- Cursor rules: none found (`.cursor/rules/` and `.cursorrules` absent).
- Copilot rules: none found (`.github/copilot-instructions.md` absent).

## Debugging
- Profile loading: `zsh -x -i -c 'exit'` (verbose shell startup)
- Install debug: `./install.sh -v` (verbose output), `./install.sh -u` (uninstall/cleanup)
- ShellCheck fails on sourced files: Add `# shellcheck source=/dev/null` or disable directives.
- Profile not loading: Verify `~/.zshrc` points to `profile/zshrc.sh` via symlink.
