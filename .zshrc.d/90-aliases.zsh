alias tmux='tmux -2'
if hash eza 2> /dev/null; then
  alias ls=eza
  alias l=eza
  alias ll='eza -l --group'
  alias lla='eza -la'
  alias la='eza -a'
  alias tree='eza --tree'
else
  alias ls='ls --color'
  alias l='ls -lFh'
  alias la='ls -a'
  alias lr='ls -tRFh'   # sorted by date,recursive,show type,human readable
  alias lt='ls -ltFh'   # long list,sorted by date,show type,human readable
  alias ll='ls -l' # long list
fi
if hash docker-compose 2> /dev/null; then
  alias dc=docker-compose
else
  alias dc='docker compose'
fi
alias pubssh='ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'
