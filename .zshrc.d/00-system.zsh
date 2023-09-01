if [ -d /etc/zsh_completion.d ]; then
  for file in /etc/zsh_completion.d/*; do
    source $file
  done
fi
