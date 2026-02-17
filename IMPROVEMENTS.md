# Improvement Plan

## 1) Make Lint Actionable
Goal: Turn `./scripts/lint.sh` into a reliable quality gate.
- Audit current `shellcheck` findings and categorize as fixable vs. intentional.
- Fix high-signal warnings (quoting, redirections, `cd` safety, missing shell directive).
- For intentional patterns, add `# shellcheck disable=SCxxxx` with brief justification.
- Decide whether to lint `dotfiles/sh_config.d` as `bash` or `zsh` and pass `-s` to shellcheck.
- Update `scripts/lint.sh` to reflect the chosen scope and add `--severity` if needed.

## 2) Add Compatibility Notes
Goal: Clarify OS/tooling assumptions to reduce breakage.
- Document supported OS targets (macOS, Linux) and known differences (GNU/BSD utils).
- Note required tools (e.g., `shellcheck`, `git`, `systemd` for `systemd/` usage).
- Add bash version expectations if any scripts rely on `bash` 4+ behavior.

## 3) Minimal Test/Verification Strategy
Goal: Provide low-effort checks for critical scripts.
- Add a "Smoke Tests" section to `README.md` with sample commands.
- Add dry-run flags or safe read-only modes for critical scripts when feasible.
- Identify 2–3 critical scripts (e.g., `install.sh`, `cloudflare-ddns.sh`) and define expected outputs.

## 4) Standardize Shell Directives
Goal: Remove ambiguity about which shell each file targets.
- Add shebangs or shellcheck directives to `dotfiles/sh_config.d/*.sh`.
- Ensure `bash`-specific features aren’t used in `sh`-intended files.
- Align file names or headers to indicate `bash` vs `zsh` intent.

## 5) Document Installer Behavior
Goal: Make install/uninstall operations safe and predictable.
- Describe symlink behavior, backup naming, and restore behavior.
- Clarify `INSTALL_PREFIX`, `DOTFILES_ROOT`, `CONFIG_ROOT` precedence.
- Provide a short "Rollback" note if installation is interrupted.

## 6) Script Index
Goal: Improve discoverability.
- Add `scripts/README.md` listing script names, purposes, and example usage.
- Keep each entry to 1–2 lines with a minimal example.

## 7) Consistent Error Handling
Goal: Reduce runtime surprises in scripts.
- Adopt `set -euo pipefail` where safe; document exceptions.
- Replace unsafe `cd` with `cd ... || exit` or `return`.
- Quote variable expansions and use `printf` safely.

## 8) Centralize Security Notes
Goal: Prevent accidental exposure of secrets.
- Add a "Security & Credentials" section in `README.md`.
- Note permission requirements (e.g., `chmod 600` on credentials).
- Add `.gitignore` entries for known local secret files if needed.

## 9) Add CI for Linting
Goal: Prevent regressions without manual checks.
- Add a GitHub Actions workflow that runs `./scripts/lint.sh`.
- Optionally add a quick `bash -n` syntax check for all scripts.
- Keep CI lightweight; no external deps beyond `shellcheck`.

## 10) Commit/PR Checklist
Goal: Encourage consistent contributions.
- Add a short checklist to `README.md` or `AGENTS.md`:
  - Run `./scripts/lint.sh`
  - Verify install/uninstall
  - Add/update usage notes for new scripts
  - Mention any OS-specific constraints

## Suggested Order of Execution
1. Make lint actionable (unblocks other work).
2. Standardize shell directives.
3. Fix error handling/quoting issues.
4. Add compatibility notes and installer documentation.
5. Add script index.
6. Add security notes.
7. Add CI workflow.
8. Add commit/PR checklist.
