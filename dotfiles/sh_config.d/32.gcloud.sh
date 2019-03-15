# -*- sh -*-
# 
# Include gcloud functions, autocomplete and tools
#
# @author Thomas Malt
#

if [[ -e $(command -v gcloud) ]]; then
  [ -t 0 ] && echo -e "$ICON_OK Found gcloud. Setting up completion."
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
      [ -t 0 ] && echo -e "   $ICON_ERR Don't know path to include files for $(setuptype)"
      ;;
  esac
else
  [ -t 0 ] && echo -e "$ICON_ERR google-cloud-sdk not found. Skipping."
fi 

