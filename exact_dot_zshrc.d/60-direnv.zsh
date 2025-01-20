# old hook
# if hash direnv 2> /dev/null; then source <(direnv hook zsh); fi
if hash direnv 2>/dev/null; then
  (( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
fi
