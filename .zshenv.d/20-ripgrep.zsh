if hash rg 2> /dev/null; then
  export FZF_DEFAULT_COMMAND='rg --files --follow'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
fi
