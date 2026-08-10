# -*- sh -*-
# shellcheck shell=bash
# shellcheck disable=SC2154,SC2262,SC2263
# Shell integrations migrated from Oh My Zsh plugins.

if [ -n "${ZSH_VERSION:-}" ]; then
    # GitHub CLI and Rust provide their own zsh completion scripts.
    if command -v gh >/dev/null 2>&1; then
        # shellcheck disable=SC1090
        source <(gh completion -s zsh)
    fi

    if command -v rustup >/dev/null 2>&1; then
        # shellcheck disable=SC1090
        source <(rustup completions zsh rustup)

        cargo_completion_dir="$(rustc --print sysroot 2>/dev/null)/share/zsh/site-functions"
        if [ -r "$cargo_completion_dir/_cargo" ]; then
            fpath+=("$cargo_completion_dir")
            autoload -Uz _cargo
            compdef _cargo cargo
        fi
        unset cargo_completion_dir
    fi

    if command -v npm >/dev/null 2>&1; then
        _npm_completion() {
            local saved_ifs="$IFS"

            # shellcheck disable=SC2046
            compadd -- $(COMP_CWORD=$((CURRENT - 1)) \
                COMP_LINE="$BUFFER" \
                COMP_POINT=0 \
                npm completion -- "${words[@]}" 2>/dev/null)
            IFS="$saved_ifs"
        }
        compdef _npm_completion npm

        npm_toggle_install_uninstall() {
            local line

            for line in "$BUFFER" \
                "${history[$((HISTCMD - 1))]}" \
                "${history[$((HISTCMD - 2))]}"; do
                case "$line" in
                    "npm uninstall"*)
                        BUFFER="${line/npm uninstall/npm install}"
                        (( CURSOR = CURSOR + 2 ))
                        ;;
                    "npm install"*)
                        BUFFER="${line/npm install/npm uninstall}"
                        (( CURSOR = CURSOR + 2 ))
                        ;;
                    "npm un "*)
                        BUFFER="${line/npm un/npm install}"
                        (( CURSOR = CURSOR + 5 ))
                        ;;
                    "npm i "*)
                        BUFFER="${line/npm i/npm uninstall}"
                        (( CURSOR = CURSOR + 8 ))
                        ;;
                    *)
                        continue
                        ;;
                esac
                return 0
            done

            BUFFER="npm install"
            CURSOR=${#BUFFER}
        }
        zle -N npm_toggle_install_uninstall
        bindkey -M emacs '^[OQ^[OQ' npm_toggle_install_uninstall
        bindkey -M vicmd '^[OQ^[OQ' npm_toggle_install_uninstall
        bindkey -M viins '^[OQ^[OQ' npm_toggle_install_uninstall
    fi

    if command -v pip >/dev/null 2>&1; then
        # shellcheck disable=SC1090
        source <(pip completion --zsh)
    elif command -v pip3 >/dev/null 2>&1; then
        # shellcheck disable=SC1090
        source <(pip3 completion --zsh)
    fi

    if command -v yarn >/dev/null 2>&1; then
        if zstyle -T ':omz:plugins:yarn' global-path; then
            if [[ -d "$HOME/.yarn/bin" ]]; then
                yarn_bin="$HOME/.yarn/bin"
            else
                yarn_bin="$(yarn global bin 2>/dev/null)"
            fi

            if [[ -d "$yarn_bin" ]] && (( ! ${path[(Ie)$yarn_bin]} )); then
                path+=("$yarn_bin")
            fi
            unset yarn_bin
        fi
    fi

    node-docs() {
        local section="${1:-all}"

        open_command "https://nodejs.org/docs/$(node --version)/api/${section}.html"
    }

    wake() {
        local config_file="$HOME/.wakeonlan/$1"

        if [[ ! -f "$config_file" ]]; then
            print -u2 "ERROR: There is no configuration file at \"$config_file\"."
            return 1
        fi

        if (( ! $+commands[wakeonlan] )); then
            print -u2 "ERROR: Can't find \"wakeonlan\". Are you sure it's installed?"
            return 1
        fi

        wakeonlan -f "$config_file"
    }

    alias h='history'
    alias hl='history | less'
    alias hs='history | grep'
    alias hsi='history | grep -i'

    alias npmg='npm i -g '
    alias npmS='npm i -S '
    alias npmd='npm i -D '
    alias npmF='npm i -f'
    alias npmE='PATH="$(npm bin)":"$PATH"'
    alias npmO='npm outdated'
    alias npmU='npm update'
    alias npmV='npm -v'
    alias npmL='npm list'
    alias npmL0='npm ls --depth=0'
    alias npmst='npm start'
    alias npmt='npm test'
    alias npmR='npm run'
    alias npmP='npm publish'
    alias npmI='npm init'
    alias npmi='npm info'
    alias npmSe='npm search'
    alias npmrd='npm run dev'
    alias npmrb='npm run build'

    alias y='yarn'
    alias ya='yarn add'
    alias yad='yarn add --dev'
    alias yap='yarn add --peer'
    alias yb='yarn build'
    alias ycc='yarn cache clean'
    alias yd='yarn dev'
    alias yf='yarn format'
    alias yh='yarn help'
    alias yi='yarn init'
    alias yin='yarn install'
    alias yln='yarn lint'
    alias ylnf='yarn lint --fix'
    alias yp='yarn pack'
    alias yrm='yarn remove'
    alias yrun='yarn run'
    alias ys='yarn serve'
    alias yst='yarn start'
    alias yt='yarn test'
    alias ytc='yarn test --coverage'
    alias yui='yarn upgrade-interactive'
    alias yup='yarn upgrade'
    alias yv='yarn version'
    alias yw='yarn workspace'
    alias yws='yarn workspaces'
    alias yy='yarn why'

    if zstyle -t ':omz:plugins:yarn' berry; then
        alias yuil='yui'
        alias yii='yarn install --immutable'
        alias yifl='yarn install --immutable'
        alias ydlx='yarn dlx'
        alias yn='yarn node'
    else
        alias yuil='yarn upgrade-interactive --latest'
        alias yii='yarn install --frozen-lockfile'
        alias yifl='yarn install --frozen-lockfile'
        alias yga='yarn global add'
        alias ygls='yarn global list'
        alias ygrm='yarn global remove'
        alias ygu='yarn global upgrade'
        alias yls='yarn list'
        alias yout='yarn outdated'
        alias yuca='yarn global upgrade && yarn cache clean'
    fi

    if command -v pip >/dev/null 2>&1; then
        alias pip='noglob pip'
    else
        alias pip='noglob pip3'
    fi
    alias pipi='pip install'
    alias pipu='pip install --upgrade'
    alias pipun='pip uninstall'
    alias pipgi='pip freeze | grep'
    alias piplo='pip list -o'
    alias pipreq='pip freeze > requirements.txt'
    alias pipir='pip install -r requirements.txt'

    if [[ -d "${XDG_CACHE_HOME:-$HOME/.cache}/pip" ]]; then
        ZSH_PIP_CACHE_FILE="${XDG_CACHE_HOME:-$HOME/.cache}/pip/zsh-cache"
    else
        ZSH_PIP_CACHE_FILE="$HOME/.pip/zsh-cache"
    fi
    ZSH_PIP_INDEXES=(https://pypi.org/simple/)

    zsh-pip-clear-cache() {
        rm -f "$ZSH_PIP_CACHE_FILE"
        unset piplist
    }

    zsh-pip-clean-packages() {
        sed -n '/<a href/ s/.*>\([^<]\{1,\}\).*/\1/p'
    }

    zsh-pip-cache-packages() {
        local index
        local tmp_cache

        mkdir -p "${ZSH_PIP_CACHE_FILE:h}"
        [ -f "$ZSH_PIP_CACHE_FILE" ] && return 0

        print -n '(...caching package index...)'
        tmp_cache="${TMPDIR:-/tmp}/zsh-pip-cache.$$"
        : >"$tmp_cache"
        for index in "${ZSH_PIP_INDEXES[@]}"; do
            curl -L "$index" 2>/dev/null | zsh-pip-clean-packages >>"$tmp_cache"
        done
        sort "$tmp_cache" | uniq | tr '\n' ' ' >"$ZSH_PIP_CACHE_FILE"
        rm -f "$tmp_cache"
    }

    pipupall() {
        local xargs_command='xargs --no-run-if-empty'

        # shellcheck disable=SC2034
        xargs --version 2>/dev/null | grep -q GNU || xargs_command='xargs'
        pip list --outdated | awk 'NR > 2 { print $1 }' | ${=xargs_command} pip install --upgrade
    }

    pipunall() {
        local xargs_command='xargs --no-run-if-empty'

        # shellcheck disable=SC2034
        xargs --version 2>/dev/null | grep -q GNU || xargs_command='xargs'
        pip list --format freeze | cut -d= -f1 | ${=xargs_command} pip uninstall
    }

    pipig() {
        pip install "git+https://github.com/$1.git"
    }
    compdef _pip pipig

    pipigb() {
        pip install "git+https://github.com/$1.git@$2"
    }
    compdef _pip pipigb

    pipigp() {
        pip install "git+https://github.com/$1.git@refs/pull/$2/head"
    }
    compdef _pip pipigp
fi
