# Setup fzf
# ---------
if [[ ! "$PATH" == *$HOME/.fzf/bin* ]]; then
  #export PATH="${PATH:+${PATH}:}$HOME/.fzf/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$HOME/.fzf/shell/completion.zsh" 2> /dev/null

# Key bindings
# ------------
[ -f "$HOME/.fzf/shell/key-bindings.zsh" ] && source "$HOME/.fzf/shell/key-bindings.zsh"

# fzf functions for git
#autoload fbr fco fco_preview
