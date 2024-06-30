if [ -d "$HOME/.asdf/bin" ]; then
  PATH_add "$HOME/.asdf/bin"
elif [ -d "/opt/asdf-vm/bin" ]; then
  PATH_add "/opt/asdf-vm/bin"
fi
