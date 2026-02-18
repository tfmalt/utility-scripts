# Improvement Plan

## Status: COMPLETE (2025-02-17)

All improvement items have been implemented.

---

## Summary

| # | Item | Status |
|---|------|--------|
| 1 | Make Lint Actionable | COMPLETE |
| 2 | Add Compatibility Notes | COMPLETE |
| 3 | Minimal Test/Verification | COMPLETE |
| 4 | Standardize Shell Directives | COMPLETE |
| 5 | Document Installer Behavior | COMPLETE |
| 6 | Script Index | COMPLETE |
| 7 | Consistent Error Handling | COMPLETE |
| 8 | Centralize Security Notes | COMPLETE |
| 9 | Add CI for Linting | COMPLETE |
| 10 | Commit/PR Checklist | COMPLETE |

---

## Completed Items

### 1) Make Lint Actionable
- `scripts/lint.sh` runs shellcheck on all scripts
- All 40+ files pass with no warnings
- `.shellcheckrc` configured with necessary disables

### 2) Add Compatibility Notes
- Added to `README.md`: Supported Platforms, Required Tools, Optional Tools, Platform Differences

### 3) Minimal Test/Verification Strategy
- Added "Verification / Smoke Tests" section to `README.md`
- Includes quick commands and expected outputs table

### 4) Standardize Shell Directives
- Added `# shellcheck shell=bash` to all config files in `dotfiles/sh_config.d/`
- Added directive to `dotfiles/zshrc.sh` and `dotfiles/bashrc.sh`

### 5) Document Installer Behavior
- Added "Installer Behavior" section to `README.md`
- Documents symlink creation, backup strategy, uninstall/recovery, and interrupted installation handling

### 6) Script Index
- Created `scripts/README.md` with descriptions and usage examples for all scripts

### 7) Consistent Error Handling
- Fixed unquoted variable expansions in `zshrc.sh`, `bashrc.sh`, `30.platformio.sh`, `31.cargo.sh`, `91.sbanken.sh`
- All files now use proper quoting: `"$VAR"` instead of `$VAR`

### 8) Centralize Security Notes
- Added "Security & Credentials" section to `README.md`
- Documents credential files, required permissions, permission checks, avoiding leaks, and SSH agent

### 9) Add CI for Linting
- `.github/workflows/shellcheck.yml` already exists and is properly configured
- Triggers on push to main/master and PRs

### 10) Commit/PR Checklist
- Added "PR Checklist" section to `AGENTS.md` with verification steps
