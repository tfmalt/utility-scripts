# -*- sh -*-
# shellcheck shell=bash
# Ensure Powerlevel10k instant prompt is disabled (set as early as possible)

if [ -n "$ZSH_VERSION" ]; then
  typeset -g POWERLEVEL10K_INSTANT_PROMPT=off
fi
