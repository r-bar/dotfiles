# setup asfh version manager

## arch package install location
#if [ -f /opt/asdf-vm/asdf.sh ]; then
#  source /opt/asdf-vm/asdf.sh
## git repo clone installation from README
#elif [ -f $HOME/.asdf/asdf.sh ]; then
#  source $HOME/.asdf/asdf.sh
#fi

#if hash asdf 2> /dev/null; then
#  PLUGINS="$(asdf plugin list)"

#  if ! grep nodejs > /dev/null 2>&1 <<< "$PLUGINS"; then
#    asdf plugin add nodejs
#    bash -c '${ASDF_DATA_DIR:=$HOME/.asdf}/plugins/nodejs/bin/import-release-team-keyring'
#  fi

#  if ! grep python > /dev/null 2>&1 <<< "$PLUGINS"; then
#    asdf plugin add python
#  fi

#  if ! grep ruby > /dev/null 2>&1 <<< "$PLUGINS"; then
#    asdf plugin add ruby
#  fi

#  alias yay="PATH=$(getconf PATH) yay"
#fi
