if [ -d "$HOME/.asdf/bin" ]; then
  export PATH="$HOME/.asdf/shims:${PATH}:$HOME/.asdf/bin"
fi
