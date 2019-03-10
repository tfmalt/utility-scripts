# -*- sh -*-
# @author Thomas Malt
#

#only run if shell is zsh

rustc_version() {
  [[ -z $(command -v rustc) ]] && return 127

  rustc --version | awk '{print $2}'
  return 0
}

custom_rust() {
  if [[ -e Cargo.toml ]] || [[ $(find . -maxdepth 1 -name '*.rs' -print -quit) ]]; then
    echo -e "\ue7a8 $(rustc_version)"
  fi
}

custom_js() {
  if [[ -e package.json ]] || [[ $(find . -maxdepth 1 -name '*.js' -print -quit) ]]; then
    echo -e "\ue74e"
  fi
}

if [[ $SHELL == *zsh ]] && [[ -d $HOME/.oh-my-zsh ]]; then

  [ -t 0 ] && echo "$ICON_OK Shell is zsh and found oh-my-zsh. Doing configuration."
  export ZSH="/Users/tm/.oh-my-zsh"

  # Set name of the theme to load --- if set to "random", it will
  # load a random theme each time oh-my-zsh is loaded, in which case,
  # to know which specific one was loaded, run: echo $RANDOM_THEME
  # See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes

  ZSH_THEME="powerlevel9k/powerlevel9k"
  # ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

  # Uncomment the following line to use case-sensitive completion.
  # CASE_SENSITIVE="true"

  # Uncomment the following line to use hyphen-insensitive completion.
  # Case-sensitive completion must be off. _ and - will be interchangeable.
  # HYPHEN_INSENSITIVE="true"

  # Uncomment the following line to disable bi-weekly auto-update checks.
  # DISABLE_AUTO_UPDATE="true"

  # Uncomment the following line to change how often to auto-update (in days).
  # export UPDATE_ZSH_DAYS=13

  # Uncomment the following line to disable colors in ls.
  # DISABLE_LS_COLORS="true"

  # Uncomment the following line to disable auto-setting terminal title.
  # DISABLE_AUTO_TITLE="true"

  # Uncomment the following line to enable command auto-correction.
  # ENABLE_CORRECTION="true"

  # Uncomment the following line to display red dots whilst waiting for 
  # completion.
  # COMPLETION_WAITING_DOTS="true"

  # Uncomment the following line if you want to disable marking untracked files
  # under VCS as dirty. This makes repository status check for large repositories
  # much, much faster.
  # DISABLE_UNTRACKED_FILES_DIRTY="true"

  # Uncomment the following line if you want to change the command execution time
  # stamp shown in the history command output.
  # You can set one of the optional three formats:
  # "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
  # or set a custom format using the strftime function format specifications,
  # see 'man strftime' for details.

  HIST_STAMP="yyyy-mm-dd"
  ZSH_DISABLE_COMPFIX=true
  DEFAULT_USER="tm"
  plugins=(
    git
    osx
    vi-mode
    cargo
  )

  POWERLEVEL9K_MODE='nerdfont-complete'
  POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"
  POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(
    context
    dir 
    dir_writable
    nvm
    custom_rust
    custom_js
    vcs
  )

  POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(
      status 
      vi_mode
      background_jobs 
      command_execution_time
      time
  )

  POWERLEVEL9K_CUSTOM_RUST="custom_rust"
  POWERLEVEL9K_CUSTOM_JS="custom_js"
  POWERLEVEL9K_CUSTOM_JS_BACKGROUND='226'
  POWERLEVEL9K_TIME_FORMAT="%D{%H:%M}"
  POWERLEVEL9K_CUSTOM_RUST_BACKGROUND='166'
  POWERLEVEL9K_ROOT_INDICATOR_BACKGROUND='160'
  POWERLEVEL9K_ROOT_INDICATOR_FOREGROUND='white'
  POWERLEVEL9K_CONTEXT_ROOT_BACKGROUND='160'
  POWERLEVEL9K_CONTEXT_ROOT_FOREGROUND='white'
  POWERLEVEL9K_VI_INSERT_MODE_STRING="INSERT"
  POWERLEVEL9K_VI_COMMAND_MODE_STRING="NORMAL"
  POWERLEVEL9K_VI_MODE_INSERT_BACKGROUND='240'
  POWERLEVEL9K_VI_MODE_INSERT_FOREGROUND='white'
  POWERLEVEL9K_VI_MODE_NORMAL_BACKGROUND='240'
  POWERLEVEL9K_VI_MODE_NORMAL_FOREGROUND='black'
  POWERLEVEL9K_STATUS_OK_BACKGROUND='238'
  POWERLEVEL9K_HOME_FOLDER_ABBREVIATION=""

  source $ZSH/oh-my-zsh.sh
else
  [ -t 0 ] && echo -e "$ICON_ERR zsh not running ($0). Skipping zsh setup."
fi

