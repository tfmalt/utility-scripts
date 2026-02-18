# Scripts

Standalone utility scripts in this repository.

## cloudflare-ddns.sh

Updates Cloudflare DNS A records when your external IP changes. Designed for systemd timer or cron.

```bash
./scripts/cloudflare-ddns.sh           # Check and update if IP changed
./scripts/cloudflare-ddns.sh --force   # Force update regardless of cached IP
./scripts/cloudflare-ddns.sh --verbose # Enable debug output
```

Requires: `flarectl`, `dig`, `curl`, credentials in `~/.config/cloudflare/credentials`

## install-cloudflare-ddns.sh

Interactive setup for the Cloudflare DDNS system. Configures DNS records and installs systemd user timer.

```bash
./scripts/install-cloudflare-ddns.sh
```

Requires: `flarectl`, `dig`, `curl`, `systemctl`

## lint.sh

Runs shellcheck on all shell scripts in the repository.

```bash
./scripts/lint.sh
```

Requires: `shellcheck`

## lspd.bash

Lists Perl module dependencies from `.pm` and `.t` files. Outputs in cpanfile format.

```bash
./scripts/lspd.bash           # Scan current directory
./scripts/lspd.bash /path/to  # Scan specific directory
```

## spotify-cache-stats.sh

Live monitor for Squeezebox server's Spotify cache directory. Shows cache size, open files, and recent entries.

```bash
./scripts/spotify-cache-stats.sh
```

Requires: `sudo` access for `lsof`, specific cache path for Squeezebox server
