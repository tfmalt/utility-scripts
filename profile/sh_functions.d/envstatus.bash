#
# envstatus - report the status of environment tools and configuration
#
# Copyright (c) 2024 Thomas Malt <thomas@malt.no>
# License: MIT
#
# Usage:
#   envstatus
#   envstatus disable <tool>
#   envstatus enable <tool>
#   envstatus disabled
#   envstatus help
#
envstatus() {
    local _profile="${PROFILE_DIR:-${PROFILE:-}}"
    local _hosttype
    _hosttype=$(setuptype)
    local _width
    _width="${COLUMNS:-}"
    if [ -z "$_width" ]; then
        _width=$(tput cols 2>/dev/null || echo 80)
    fi
    case "$_width" in
        ''|*[!0-9]*) _width=80 ;;
        0) _width=80 ;;
    esac

    local _col_bold="${COL_BOLD:-}"
    local _col_dim="${COL_DIM:-}"
    local _col_stop="${COL_STOP:-}"
    local _icon_ok="${ICON_OK:-[ok]}"
    local _icon_info="${ICON_INFO:-[i]}"
    local _icon_warn="${ICON_WARN:-[!]}"
    local _icon_err="${ICON_ERR:-[x]}"
    local _config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/envstatus"
    local _config_file="$_config_dir/disabled-tools.conf"
    local _cmd="${1:-status}"

    local _sep
    printf -v _sep '%*s' "$_width" ''
    _sep=${_sep// /─}

    local _nok=0 _nwarn=0 _nerr=0 _ndisabled=0

    # --- Local helpers ----------------------------------------------------

    _section() {
        local _line
        printf '\n%b  %s%b\n' "$_col_bold" "$1" "$_col_stop"
        printf -v _line '%*s' "$_width" ''
        _line=${_line// /─}
        printf '%b%s%b\n' "$_col_dim" "$_line" "$_col_stop"
    }

    _row() {
        local _icon="$1" _name="$2" _msg="$3"
        printf '  %b  %-12s  %s\n' "$_icon" "$_name" "$_msg"
    }

    _ok() {
        _row "$_icon_ok" "$1" "$2"
        (( _nok++ )) || true
    }

    _info() {
        _row "$_icon_info" "$1" "$2"
    }

    _warn() {
        _row "$_icon_warn" "$1" "$2"
        (( _nwarn++ )) || true
    }

    _err() {
        _row "$_icon_err" "$1" "$2"
        (( _nerr++ )) || true
    }

    _tool_msg() {
        local _version="$1" _path="$2"
        printf '%-14s %s' "$_version" "$_path"
    }

    _is_known_tool() {
        case "$1" in
            mise|node|cargo|platformio|opencode|claude|gh|hass|ssh-agent|homebrew|cloudflare|profile|oh-my-zsh|vim-colors)
                return 0
                ;;
            *)
                return 1
                ;;
        esac
    }

    _is_disabled() {
        [ -f "$_config_file" ] || return 1
        grep -Fqx -- "$1" "$_config_file"
    }

    _count_disabled_tools() {
        local _line _seen='|'

        _ndisabled=0
        [ -f "$_config_file" ] || return 0

        while IFS= read -r _line; do
            [ -z "$_line" ] && continue
            _is_known_tool "$_line" || continue

            case "$_seen" in
                *"|$_line|"*) ;;
                *)
                    _seen="${_seen}${_line}|"
                    (( _ndisabled++ )) || true
                    ;;
            esac
        done < "$_config_file"
    }

    _print_help() {
        printf 'Usage:\n'
        printf '  envstatus\n'
        printf '  envstatus disable <tool>\n'
        printf '  envstatus enable <tool>\n'
        printf '  envstatus disabled\n'
        printf '  envstatus help\n\n'
        printf 'Config file: %s\n\n' "$_config_file"
        printf 'Known tools: mise, node, cargo, platformio, opencode, claude, gh, hass, ssh-agent, homebrew, cloudflare, profile, oh-my-zsh, vim-colors\n'
    }

    _disable_tool() {
        local _tool="$1"

        if ! _is_known_tool "$_tool"; then
            printf 'envstatus: unknown tool: %s\n' "$_tool" >&2
            return 2
        fi

        if ! mkdir -p "$_config_dir" 2>/dev/null; then
            printf 'envstatus: failed to create config directory: %s\n' "$_config_dir" >&2
            return 1
        fi

        if [ ! -f "$_config_file" ] && ! : > "$_config_file" 2>/dev/null; then
            printf 'envstatus: failed to create config file: %s\n' "$_config_file" >&2
            return 1
        fi

        if _is_disabled "$_tool"; then
            printf 'envstatus: %s already disabled\n' "$_tool"
            return 0
        fi

        if ! printf '%s\n' "$_tool" >> "$_config_file"; then
            printf 'envstatus: failed to update config file: %s\n' "$_config_file" >&2
            return 1
        fi

        printf 'envstatus: disabled %s\n' "$_tool"
        printf 'envstatus: config file %s\n' "$_config_file"
        return 0
    }

    _enable_tool() {
        local _tool="$1"
        local _tmp

        if ! _is_known_tool "$_tool"; then
            printf 'envstatus: unknown tool: %s\n' "$_tool" >&2
            return 2
        fi

        if [ ! -f "$_config_file" ] || ! _is_disabled "$_tool"; then
            printf 'envstatus: %s is already enabled\n' "$_tool"
            return 0
        fi

        _tmp=$(mktemp "${TMPDIR:-/tmp}/envstatus.XXXXXX") || {
            printf 'envstatus: failed to create temporary file\n' >&2
            return 1
        }

        grep -Fvx -- "$_tool" "$_config_file" > "$_tmp" || true

        if ! mv "$_tmp" "$_config_file"; then
            rm -f "$_tmp"
            printf 'envstatus: failed to update config file: %s\n' "$_config_file" >&2
            return 1
        fi

        printf 'envstatus: enabled %s\n' "$_tool"
        printf 'envstatus: config file %s\n' "$_config_file"
        return 0
    }

    _list_disabled_tools() {
        local _line

        if [ ! -f "$_config_file" ] || [ ! -s "$_config_file" ]; then
            printf 'envstatus: no disabled tools\n'
            printf 'envstatus: config file %s\n' "$_config_file"
            return 0
        fi

        printf 'Disabled tools:\n'
        while IFS= read -r _line; do
            [ -z "$_line" ] && continue
            printf '  - %s\n' "$_line"
        done < "$_config_file"

        printf 'envstatus: config file %s\n' "$_config_file"
    }

    case "$_cmd" in
        status)
            ;;
        disable)
            [ -n "${2:-}" ] || {
                _print_help >&2
                return 2
            }
            _disable_tool "$2"
            return $?
            ;;
        enable)
            [ -n "${2:-}" ] || {
                _print_help >&2
                return 2
            }
            _enable_tool "$2"
            return $?
            ;;
        disabled)
            _list_disabled_tools
            return $?
            ;;
        help|-h|--help)
            _print_help
            return 0
            ;;
        *)
            printf 'envstatus: unknown command: %s\n\n' "$_cmd" >&2
            _print_help >&2
            return 2
            ;;
    esac

    _count_disabled_tools

    # --- Header -----------------------------------------------------------

    local _uptime _uptime_raw _uptime_parsed
    _uptime_raw=$(uptime 2>/dev/null || true)
    _uptime_parsed=$(printf '%s\n' "$_uptime_raw" | sed -E 's/^.* up //; s/, *[0-9]+ users?,.*$//; s/, *load averages?:.*$//; s/, *[0-9]+ users?$//')
    if [ -n "$_uptime_parsed" ] && [ "$_uptime_parsed" != "$_uptime_raw" ]; then
        _uptime="$_uptime_parsed"
    elif [ -n "$_uptime_raw" ]; then
        _uptime="$_uptime_raw"
    else
        _uptime="unknown"
    fi
    printf '\n%b%s%b\n' "$_col_dim" "$_sep" "$_col_stop"
    printf '%b  Environment Status%b\n' "$_col_bold" "$_col_stop"
    printf '%b  %s  •  up %s%b\n' "$_col_dim" "$_hosttype" "$_uptime" "$_col_stop"
    printf '%b%s%b\n' "$_col_dim" "$_sep" "$_col_stop"

    # --- Dev Tools --------------------------------------------------------

    _section "Dev Tools"

    local _mise_data="${MISE_DATA_DIR:-$HOME/.local/share/mise}"
    local _mise_path _mise_version
    if _is_disabled "mise"; then
        _info "mise"      "disabled via local config"
    else
        _mise_path=$(command -v mise 2>/dev/null || true)
        if [ -n "$_mise_path" ]; then
            _mise_version=$(mise --version 2>/dev/null | awk '{
                for (i = 1; i <= NF; i++) {
                    if ($i ~ /^[0-9]+\.[0-9]+\.[0-9]+([-.+][0-9A-Za-z.]+)?$/) {
                        print $i
                        exit
                    }
                }
            }')
            [ -z "$_mise_version" ] && _mise_version="unknown"
            _ok  "mise"       "$(_tool_msg "$_mise_version" "$_mise_path")"
        elif [ -d "$_mise_data/shims" ]; then
            _warn "mise"      "$(_tool_msg "unknown" "$_mise_data/shims")"
        elif [ -d "$_mise_data" ]; then
            _warn "mise"      "$(_tool_msg "unknown" "$_mise_data (shims missing)")"
        else
            _err "mise"       "$(_tool_msg "missing" "-")"
        fi
    fi

    local _node_path _node_version
    if _is_disabled "node"; then
        _info "node"      "disabled via local config"
    else
        _node_path=$(command -v node 2>/dev/null || true)
        if [ -n "$_node_path" ]; then
            _node_version=$(node --version 2>/dev/null | sed 's/^v//')
            [ -z "$_node_version" ] && _node_version="unknown"
            _ok  "node"       "$(_tool_msg "$_node_version" "$_node_path")"
        else
            _err "node"       "$(_tool_msg "missing" "-")"
        fi
    fi

    local _cargo_path _cargo_version
    if _is_disabled "cargo"; then
        _info "cargo"     "disabled via local config"
    else
        _cargo_path=$(command -v cargo 2>/dev/null || true)
        if [ -n "$_cargo_path" ]; then
            _cargo_version=$(cargo --version 2>/dev/null | awk '{print $2}')
            [ -z "$_cargo_version" ] && _cargo_version="unknown"
            _ok  "cargo"      "$(_tool_msg "$_cargo_version" "$_cargo_path")"
        elif [ -d "$HOME/.cargo/bin" ]; then
            _warn "cargo"     "$(_tool_msg "unknown" "$HOME/.cargo/bin (not on PATH)")"
        else
            _err "cargo"      "$(_tool_msg "missing" "-")"
        fi
    fi

    local _piopath _platformio_win_home _pio_path _pio_version
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
    if _is_disabled "platformio"; then
        _info "platformio" "disabled via local config"
    else
        _pio_path=$(command -v pio 2>/dev/null || true)
        if [ -n "$_pio_path" ]; then
            _pio_version=$(pio --version 2>/dev/null | awk '{print $NF}')
            [ -z "$_pio_version" ] && _pio_version="unknown"
            _ok  "platformio" "$(_tool_msg "$_pio_version" "$_pio_path")"
        elif [[ -n "$_piopath" ]] && [ -d "$_piopath" ]; then
            _warn "platformio" "$(_tool_msg "unknown" "$_piopath")"
        else
            _err "platformio" "$(_tool_msg "missing" "-")"
        fi
    fi

    local _opencode_path _opencode_version
    if _is_disabled "opencode"; then
        _info "opencode"  "disabled via local config"
    else
        _opencode_path=$(command -v opencode 2>/dev/null || true)
        if [ -n "$_opencode_path" ]; then
            _opencode_version=$(opencode --version 2>/dev/null | awk '{print $1}')
            [ -z "$_opencode_version" ] && _opencode_version="unknown"
            _ok  "opencode"   "$(_tool_msg "$_opencode_version" "$_opencode_path")"
        else
            _err "opencode"   "$(_tool_msg "missing" "-")"
        fi
    fi

    local _claude_path _claude_version
    if _is_disabled "claude"; then
        _info "claude"    "disabled via local config"
    else
        _claude_path=$(command -v claude 2>/dev/null || true)
        if [ -n "$_claude_path" ]; then
            _claude_version=$(claude --version 2>/dev/null | awk '{print $1}')
            [ -z "$_claude_version" ] && _claude_version="unknown"
            _ok  "claude"     "$(_tool_msg "$_claude_version" "$_claude_path")"
        else
            _err "claude"     "$(_tool_msg "missing" "-")"
        fi
    fi

    local _gh_path _gh_version
    if _is_disabled "gh"; then
        _info "gh"        "disabled via local config"
    else
        _gh_path=$(command -v gh 2>/dev/null || true)
        if [ -n "$_gh_path" ]; then
            _gh_version=$(gh --version 2>/dev/null | awk 'NR==1 {print $3}')
            [ -z "$_gh_version" ] && _gh_version="unknown"
            _ok  "gh"         "$(_tool_msg "$_gh_version" "$_gh_path")"
        else
            _err "gh"         "$(_tool_msg "missing" "-")"
        fi
    fi

    # --- Home Automation --------------------------------------------------

    _section "Home Automation"

    if _is_disabled "hass"; then
        _info "hass"      "disabled via local config"
    elif [[ -x $HOME/.local/bin/hass-cli ]]; then
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

    local _ssh_agent_comm _ssh_agent_name
    _ssh_agent_comm=""
    _ssh_agent_name=""
    if _is_disabled "ssh-agent"; then
        _info "ssh-agent" "disabled via local config"
    else
        if [ -n "${SSH_AGENT_PID:-}" ]; then
            _ssh_agent_comm=$(ps -p "$SSH_AGENT_PID" -o comm= 2>/dev/null || true)
            _ssh_agent_name=${_ssh_agent_comm##*/}
        fi
        if [ "$_ssh_agent_name" = "ssh-agent" ]; then
            _ok   "ssh-agent" "running (pid $SSH_AGENT_PID)"
        else
            _warn "ssh-agent" "not running"
        fi
    fi

    if _is_disabled "homebrew"; then
        _info "homebrew"  "disabled via local config"
    elif command -v brew &>/dev/null; then
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
    if _is_disabled "cloudflare"; then
        _info "cloudflare" "disabled via local config"
    elif [ -f "$_cf_creds" ]; then
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

    if _is_disabled "profile"; then
        _info "profile"    "disabled via local config"
    elif [ -z "$_profile" ]; then
        _warn "profile"    "PROFILE_DIR and PROFILE are unset — run install.sh"
    fi

    if _is_disabled "oh-my-zsh"; then
        _info "oh-my-zsh" "disabled via local config"
    elif [ -d "$HOME/.oh-my-zsh" ]; then
        _ok   "oh-my-zsh" "$HOME/.oh-my-zsh"
    else
        _err  "oh-my-zsh" "not installed"
    fi

    if _is_disabled "vim-colors"; then
        _info "vim-colors" "disabled via local config"
    elif [ -n "$_profile" ]; then
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

    printf '\n%b%s%b\n' "$_col_dim" "$_sep" "$_col_stop"
    printf '  '
    printf '%b %d ok' "$_icon_ok" "$_nok"
    if [ "$_nwarn" -gt 0 ]; then
        printf '   %b %d warning' "$_icon_warn" "$_nwarn"
        [ "$_nwarn" -gt 1 ] && printf 's'
    fi
    if [ "$_nerr" -gt 0 ]; then
        printf '   %b %d error' "$_icon_err" "$_nerr"
        [ "$_nerr" -gt 1 ] && printf 's'
    fi
    if [ "$_ndisabled" -gt 0 ]; then
        printf '   %b %d disabled' "$_icon_info" "$_ndisabled"
        [ "$_ndisabled" -gt 1 ] && printf 's'
    fi
    printf '\n%b%s%b\n\n' "$_col_dim" "$_sep" "$_col_stop"

    unset -f _section _row _ok _info _warn _err _tool_msg
    unset -f _is_known_tool _is_disabled _count_disabled_tools
    unset -f _print_help _disable_tool _enable_tool _list_disabled_tools
    unset _profile _hosttype _width _sep _nok _nwarn _nerr _ndisabled _cmd
    unset _config_dir _config_file _tmp _tool _line
    unset _col_bold _col_dim _col_stop _icon_ok _icon_info _icon_warn _icon_err
    unset _uptime _uptime_raw _uptime_parsed _mise_data _mise_path _mise_version
    unset _node_path _node_version
    unset _cargo_path _cargo_version _piopath _platformio_win_home _pio_path _pio_version
    unset _opencode_path _opencode_version _claude_path _claude_version _gh_path _gh_version
    unset _ssh_agent_comm _cf_creds _perms
    unset _cs_dir _cs_link _actual _expected
}
