# -*- sh -*-
# shellcheck shell=bash
# Initialize Starship after shell integrations and before zsh UI plugins.

if [ -n "${ZSH_VERSION:-}" ] && ! envstatus_tool_disabled "starship"; then
  STARSHIP_CONFIG="${PROFILE_DIR:-${PROFILE:-}}/starship.toml"
  export STARSHIP_CONFIG

  if command -v starship >/dev/null 2>&1; then
    ZLE_RPROMPT_INDENT=0
    eval "$(starship init zsh)"

    _starship_vi_mode_update() {
      if [ "${REGION_ACTIVE:-0}" -ne 0 ]; then
        export STARSHIP_VI_MODE="VISUAL"
      elif [ "${KEYMAP:-main}" = "vicmd" ]; then
        export STARSHIP_VI_MODE="NORMAL"
      else
        unset STARSHIP_VI_MODE
      fi
      zle reset-prompt
    }

    autoload -Uz add-zle-hook-widget
    add-zle-hook-widget line-init _starship_vi_mode_update
    add-zle-hook-widget keymap-select _starship_vi_mode_update
  else
    status_err "starship" "not found; install with: brew install starship or curl -sS https://starship.rs/install.sh | sh"
  fi
fi
