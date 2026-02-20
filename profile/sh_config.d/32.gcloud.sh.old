# -*- sh -*-
# shellcheck shell=bash
#
# Include gcloud functions, autocomplete and tools
#
# @author Thomas Malt
#

if [[ -e $(command -v gcloud) ]]; then
  status_ok "gcloud" "found; setting up completion"
  case $(setuptype) in
    macbook)
      export CLOUDSDK_PYTHON=/usr/local/bin/python
      CASKPATH='/usr/local/Caskroom/google-cloud-sdk/latest/google-cloud-sdk'
      if [[ $SHELL == *zsh ]]; then
        source $CASKPATH/path.zsh.inc
        source $CASKPATH/completion.zsh.inc
      else 
        source $CASKPATH/path.bash.inc
        source $CASKPATH/completion.bash.inc
      fi
      ;;
    *)
      status_warn "gcloud" "unknown include path for $(setuptype); completion skipped"
      ;;
  esac
else
  status_err "gcloud" "google-cloud-sdk not found; setup skipped"
fi 
