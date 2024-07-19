if hash mise 2>/dev/null; then
  eval "$(mise activate $(basename $SHELL))"
  alias mr="mise run"
fi
