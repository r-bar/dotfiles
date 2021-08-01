if [ -d "$HOME/.rbenv" ]; then
  export PATH="$PATH:$HOME/.rbenv/bin"
  eval "$(rbenv init -)"
fi
