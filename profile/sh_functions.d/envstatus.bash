#
# envstatus - report the status of environment tools and configuration
#
# Copyright (c) 2024 Thomas Malt <thomas@malt.no>
# License: MIT
#
# Usage: envstatus
#
envstatus() {
    local _profile="${PROFILE_DIR:-${PROFILE:-}}"
    local _hosttype
    _hosttype=$(setuptype)
    local _width
    _width=$(tput cols 2>/dev/null || echo 60)
    [ "$_width" -gt 72 ] && _width=72

    local _sep
    _sep=$(printf "${COL_DIM}%${_width}s${COL_STOP}" | tr ' ' '─')

    local _nok=0 _nwarn=0 _nerr=0

    # --- Local helpers ----------------------------------------------------

    _section() {
        printf '\n%b  %s%b\n' "$COL_BOLD" "$1" "$COL_STOP"
        printf '%b%*s%b\n' "$COL_DIM" "$_width" '' "$COL_STOP" | tr ' ' '─'
    }

    _row() {
        local _icon="$1" _name="$2" _msg="$3"
        printf '  %b  %-12s  %s\n' "$_icon" "$_name" "$_msg"
    }

    _ok() {
        _row "$ICON_OK" "$1" "$2"
        (( _nok++ )) || true
    }

    _info() {
        _row "$ICON_INFO" "$1" "$2"
    }

    _warn() {
        _row "$ICON_WARN" "$1" "$2"
        (( _nwarn++ )) || true
    }

    _err() {
        _row "$ICON_ERR" "$1" "$2"
        (( _nerr++ )) || true
    }

    # --- Header -----------------------------------------------------------

    local _uptime
    _uptime=$(uptime | sed 's/.*up //; s/,  [0-9]* user.*//')
    printf '\n%s\n' "$_sep"
    printf '%b  Environment Status%b\n' "$COL_BOLD" "$COL_STOP"
    printf '%b  %s  •  up %s%b\n' "$COL_DIM" "$_hosttype" "$_uptime" "$COL_STOP"
    printf '%s\n' "$_sep"

    # --- Dev Tools --------------------------------------------------------

    _section "Dev Tools"

    local _mise_data="${MISE_DATA_DIR:-$HOME/.local/share/mise}"
    if command -v mise &>/dev/null; then
        _ok  "mise"       "$(mise --version 2>/dev/null)"
    elif [ -d "$_mise_data/shims" ]; then
        _ok  "mise"       "shims at $_mise_data/shims"
    elif [ -d "$_mise_data" ]; then
        _err "mise"       "data dir found but shims missing"
    else
        _err "mise"       "not installed"
    fi

    if [ -d "$HOME/.cargo/bin" ]; then
        _ok  "cargo"      "$HOME/.cargo/bin"
    else
        _err "cargo"      "$HOME/.cargo/bin not found"
    fi

    local _piopath _platformio_win_home
    case $_hosttype in
        macbook) _piopath="$HOME/.platformio/penv/bin" ;;
        windows)
            _platformio_win_home="${PLATFORMIO_WIN_HOME:-}"
            if [ -z "$_platformio_win_home" ]; then
                if [ -n "${USERPROFILE:-}" ] && command -v wslpath &>/dev/null; then
                    _platformio_win_home="$(wslpath "$USERPROFILE")"
                else
                    _platformio_win_home="/mnt/c/Users/${USER:-Default}"
                fi
            fi
            _piopath="$_platformio_win_home/.platformio/penv/Scripts"
            ;;
    esac
    if [[ -n "$_piopath" ]] && [ -d "$_piopath" ]; then
        _ok  "platformio" "$_piopath"
    else
        _err "platformio" "not found"
    fi

    if command -v opencode &>/dev/null; then
        _ok  "opencode"   "$(opencode --version 2>/dev/null || echo 'found')"
    else
        _err "opencode"   "not found — brew install anomalyco/tap/opencode"
    fi

    # --- Home Automation --------------------------------------------------

    _section "Home Automation"

    if [[ -x $HOME/.local/bin/hass-cli ]]; then
        if [ -z "${HASS_TOKEN:-}" ]; then
            _warn "hass"  "hass-cli found but HASS_TOKEN not set"
        else
            _ok   "hass"  "hass-cli found; HASS_TOKEN set"
        fi
    else
        _info "hass"      "hass-cli not installed"
    fi

    # --- Auth & Credentials -----------------------------------------------

    _section "Auth & Credentials"

    if [ -n "${SSH_AGENT_PID:-}" ] && \
       ps -p "$SSH_AGENT_PID" -o comm= 2>/dev/null | grep -q '^ssh-agent$'; then
        _ok   "ssh-agent" "running (pid $SSH_AGENT_PID)"
    else
        _warn "ssh-agent" "not running"
    fi

    if command -v brew &>/dev/null; then
        _ok   "homebrew"  "$(brew --prefix 2>/dev/null)"
        if [ -n "${HOMEBREW_GITHUB_API_TOKEN:-}" ]; then
            _ok   "homebrew"  "HOMEBREW_GITHUB_API_TOKEN set"
        else
            _warn "homebrew"  "HOMEBREW_GITHUB_API_TOKEN not set (API rate limits)"
        fi
    else
        _info "homebrew"  "not installed"
    fi

    local _cf_creds="$HOME/.config/cloudflare/credentials"
    if [ -f "$_cf_creds" ]; then
        local _perms
        _perms=$(stat -c '%a' "$_cf_creds" 2>/dev/null || stat -f '%Lp' "$_cf_creds" 2>/dev/null)
        if [ "$_perms" != "600" ]; then
            _warn "cloudflare" "insecure permissions ($_perms) — run: chmod 600 $_cf_creds"
        elif [ -n "${CF_API_TOKEN:-}" ]; then
            _ok   "cloudflare" "CF_API_TOKEN loaded"
        else
            _warn "cloudflare" "credentials file exists but CF_API_TOKEN is empty"
        fi
    else
        _info "cloudflare" "not configured (no $_cf_creds)"
    fi

    # --- Shell Config -----------------------------------------------------

    _section "Shell Config"

    if [ -z "$_profile" ]; then
        _warn "profile"    "PROFILE_DIR and PROFILE are unset — run install.sh"
    fi

    if [ -d "$HOME/.oh-my-zsh" ]; then
        _ok   "oh-my-zsh" "$HOME/.oh-my-zsh"
    else
        _err  "oh-my-zsh" "not installed"
    fi

    if [ -n "$_profile" ]; then
        local _cs_dir="$_profile/vim/awesome-vim-colorschemes"
        local _cs_link="$_profile/vim/colors"
        if [ -L "$_cs_dir" ] && [ ! -e "$_cs_dir" ]; then
            _err  "vim-colors" "awesome-vim-colorschemes is a stale symlink"
        elif [ ! -d "$_cs_dir/.git" ]; then
            _err  "vim-colors" "not cloned — run install.sh"
        elif [ -z "$(ls -A "$_cs_dir/colors" 2>/dev/null)" ]; then
            _err  "vim-colors" "colors dir empty — git submodule update --init"
        elif [ -L "$_cs_link" ] && [ ! -e "$_cs_link" ]; then
            _err  "vim-colors" "vim/colors is a stale symlink — run install.sh"
        elif [ ! -e "$_cs_link" ]; then
            _err  "vim-colors" "vim/colors not linked — run install.sh"
        elif [ -L "$_cs_link" ]; then
            local _actual _expected
            _actual=$(realpath "$_cs_link" 2>/dev/null \
                || readlink -f "$_cs_link" 2>/dev/null \
                || readlink "$_cs_link")
            _expected=$(realpath "$_cs_dir/colors" 2>/dev/null \
                || readlink -f "$_cs_dir/colors" 2>/dev/null \
                || echo "$_cs_dir/colors")
            if [ "$_actual" != "$_expected" ]; then
                _err  "vim-colors" "vim/colors wrong target: $(readlink "$_cs_link")"
            else
                _ok   "vim-colors" "colorschemes present and linked"
            fi
        else
            _ok   "vim-colors" "colorschemes present and linked"
        fi
    fi

    # --- Footer / summary -------------------------------------------------

    printf '\n%s\n' "$_sep"
    printf '  '
    printf '%b %d ok' "$ICON_OK" "$_nok"
    if [ "$_nwarn" -gt 0 ]; then
        printf '   %b %d warning' "$ICON_WARN" "$_nwarn"
        [ "$_nwarn" -gt 1 ] && printf 's'
    fi
    if [ "$_nerr" -gt 0 ]; then
        printf '   %b %d error' "$ICON_ERR" "$_nerr"
        [ "$_nerr" -gt 1 ] && printf 's'
    fi
    printf '\n%s\n\n' "$_sep"

    unset -f _section _row _ok _info _warn _err
    unset _profile _hosttype _width _sep _nok _nwarn _nerr
    unset _uptime _mise_data _piopath _platformio_win_home _cf_creds _perms _cs_dir _cs_link _actual _expected
}
