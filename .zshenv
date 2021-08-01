export HISTFILE=~/.histfile
export HISTSIZE=1000
export SAVEHIST=10000
export PROMPT_COMMAND=''
export PS1='$ '
export SOLARIZED_THEME=dark
# prevents python's venv/bin/activate from modifying $PS1
export VIRTUAL_ENV_DISABLE_PROMPT=1

export SHARE_HISTORY=1
export ZSH_AUTOSUGGEST_USE_ASYNC=1

export PATH="$HOME/.local/bin:$PATH"
#if !grep $HOME/.local/bin <<< "$PATH" 1>&2 2> /dev/null; then
#  echo hit
#  export PATH="$HOME/.local/bin:$PATH"
#fi

unsetopt nomatch

for file in $HOME/.zshenv.d/*.zsh; do source $file; done
