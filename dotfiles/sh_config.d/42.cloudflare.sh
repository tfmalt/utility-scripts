# -*- sh -*-
# @author Thomas Malt
#
# Configure Cloudflare API token for flarectl CLI tool.
# Loads credentials from ~/.config/cloudflare/credentials file if it exists.
#
# Setup:
#   1. Create directory: mkdir -p ~/.config/cloudflare
#   2. Create credentials file: touch ~/.config/cloudflare/credentials
#   3. Set permissions: chmod 600 ~/.config/cloudflare/credentials
#   4. Add your token: echo "export CF_API_TOKEN=your_token_here" > ~/.config/cloudflare/credentials
#
# The CF_API_TOKEN environment variable is used by flarectl for authentication.

CLOUDFLARE_CREDENTIALS="$HOME/.config/cloudflare/credentials"

if [ -f "$CLOUDFLARE_CREDENTIALS" ]; then
  # Check file permissions for security
  # Use lowercase %a for Linux (numeric), uppercase %Lp for macOS (octal)
  PERMS=$(stat -c '%a' "$CLOUDFLARE_CREDENTIALS" 2>/dev/null || stat -f '%Lp' "$CLOUDFLARE_CREDENTIALS" 2>/dev/null)
  if [ "$PERMS" != "600" ]; then
    [ -t 0 ] && echo -e "${ICON_WARN:-⚠️ } Warning: $CLOUDFLARE_CREDENTIALS has insecure permissions. Run: chmod 600 $CLOUDFLARE_CREDENTIALS"
  fi
  unset PERMS

  # Source the credentials file
  source "$CLOUDFLARE_CREDENTIALS"

  if [ -n "$CF_API_TOKEN" ]; then
    export CF_API_TOKEN
    [ -t 0 ] && echo -e "${ICON_OK:-✓} Loaded Cloudflare API token from $CLOUDFLARE_CREDENTIALS"
  else
    [ -t 0 ] && echo -e "${ICON_WARN:-⚠️ } $CLOUDFLARE_CREDENTIALS exists but CF_API_TOKEN not set"
  fi
else
  [ -t 0 ] && echo -e "${ICON_INFO:-ℹ️ } Cloudflare credentials not found at $CLOUDFLARE_CREDENTIALS"
fi

# Cleanup
unset CLOUDFLARE_CREDENTIALS
