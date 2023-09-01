if [ -d "$HOME/.asdf/bin" ]; then
  export PATH="${PATH}:$HOME/.asdf/bin"
  #export PATH="$HOME/.asdf/shims:${PATH}:$HOME/.asdf/bin"
elif [ -d "/opt/asdf-vm/bin" ]; then
  export PATH="$PATH:/opt/asdf-vm/bin"
fi
