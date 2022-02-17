alias tmux='tmux -2'
if hash exa 2> /dev/null; then
  alias ls=exa
  alias l=exa
  alias ll='exa -l --group'
  alias lla='exa -la'
  alias la='exa -a'
  alias tree='exa --tree'
else
  alias ls='ls --color'
  alias l='ls -lFh'
  alias la='ls -a'
  alias lr='ls -tRFh'   # sorted by date,recursive,show type,human readable
  alias lt='ls -ltFh'   # long list,sorted by date,show type,human readable
  alias ll='ls -l' # long list
fi
alias dc=docker-compose
alias pubssh='ssh -o "UserKnownHostsFile=/dev/null" -o "StrictHostKeyChecking=no"'
