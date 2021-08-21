# Setup fzf
# ---------
if ! hash fzf 2> /dev/null && [[ -d $HOME/.fzf/bin ]] && [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

# Auto-completion
# ---------------
COMPLETION=(
  $HOME/.fzf/shell/completion.zsh
  /usr/share/fzf/completion.zsh
)
for file in $COMPLETION[@]; do
  if [[ $- == *i* ]] && [[ -f $file ]]; then
    echo found completion
    source $file
    break
  fi
done

# Key bindings
# ------------
KEY_BINDINGS=(
  "$HOME/.fzf/shell/key-bindings.zsh"
  /usr/share/fzf/key-bindings.zsh
)
for file in $KEY_BINDINGS[@]; do
  if [ -f $file ]; then
    echo fount keys
    source $file
    break
  fi
done
