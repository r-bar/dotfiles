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

ZSHENV_BENCHMARK=0

for file in $HOME/.zshenv.d/*.zsh; do
  if [ $ZSHENV_BENCHMARK -eq 1 ]; then start=$(date +%s.%N); fi
  source $file
  if [ $ZSHENV_BENCHMARK -eq 1 ]; then
    stop=$(date +%s.%N)
    echo "$(($stop - $start))\t$file"
  fi
done

# Begin added by argcomplete
fpath=( /usr/lib/python3.12/site-packages/argcomplete/bash_completion.d "${fpath[@]}" )
# End added by argcomplete
