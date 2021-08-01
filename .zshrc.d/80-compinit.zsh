# initialize zsh completions
autoload -Uz compinit promptinit && compinit && promptinit

# initialize bash completions functions
autoload -U +X bashcompinit && bashcompinit
