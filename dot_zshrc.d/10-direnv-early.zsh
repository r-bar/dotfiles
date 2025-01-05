# This must be executed before the p10k instant prompt block.
# see: https://github.com/romkatv/powerlevel10k?tab=readme-ov-file#how-do-i-initialize-direnv-when-using-instant-prompt
if hash direnv 2>/dev/null; then
  (( ${+commands[direnv]} )) && emulate zsh -c "$(direnv export zsh)"
fi
