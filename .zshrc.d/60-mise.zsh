if hash mise 2>/dev/null; then
  eval "$(mise activate $(basename $SHELL))"
  alias mr="mise run"
  alias m="mise"
  alias mt="mise tasks"

  compfile=~/.local/share/zinit/completions/_mise
  if [ ! -f $compfile ]; then
    mkdir -p $(dirname $compfile)
    mise completion zsh > $compfile
  fi
fi
