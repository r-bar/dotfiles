if false && [ -d ~/.pyenv ]; then
  export PYENV_ROOT="$HOME/.pyenv"
  export PATH="$PATH:$PYENV_ROOT/bin"
  export PYENV_VIRTUALENV_DISABLE_PROMPT=1
  export PYENV_VIRTUALENV_VERBOSE_ACTIVATE=1
  eval "$(pyenv init -)"
  eval "$(pyenv virtualenv-init -)"
fi
